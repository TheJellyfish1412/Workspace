--[[
	RoWorld (Airfront) helper — guiV3 game UI.   ** VERSION 3 copy ** (Source/sim/versions/version3/lua/main.lua)

	Version 3 = strategy v1 plans (autoplay.lua play_strat). Differences from Source/main.lua:
	  - RW_Strat on, the version 2 model off (RW_Model / RW_ModelOnly: it would play before the plans), forced
	    at load and again for 60 s (saved guiV3 settings may load over them)
	  - it reloads itself from /lua/v3/main.lua (bridge) or RoWorld/v3/main.lua after a teleport
	  - autoplay.lua, rc.lua, guiV3.lua are version 3's own (versions/version3/lua, served by script/bridge_v3.py;
	    workspace copies in RoWorld/v3/)
	Loaded by Delta/Autoexecute/rw_v3_loader.lua (versions/version3/script). Copied from Source/main.lua on
	2026-11-19: later edits there are not in this copy.

	Tabs
	Main     Auto Play / Auto Spawn, Auto Join, and Solo / World selection.
	Record   Manage recordings, auto-delete stale unfinished matches, and log every cleanup check.
	Main page 2  Solo speed and Auto Play tuning.

	Recordings store real matches exactly as the server sends them: the snapshot at join (or after a
	           resync) and every delta, as raw Protocol buffers. Offline, the game's own GameState.lua
	           replays them (Source/lune_sim/realmatch/) into the same format as the training data.
	           A fresh snapshot is requested every 3000 ticks so the replay can be checked exactly.

	Files (executor workspace)
	  RoWorld/main.lua                        this script (used to reload itself after a teleport)
	  RoWorldRecord/<utc>_<job>/meta.json     match info, start/end, counters
	  RoWorldRecord/<utc>_<job>/snap_<k>_<owner>.bin   raw snapshot buffer k
	  RoWorldRecord/<utc>_<job>/deltas_<n>.bin          records in arrival order:
	        u8 1, u32 lenA, u32 lenB (0xFFFFFFFF = none), A bytes, B bytes   -- a delta (_on_delta(A, B))
	        u8 2, u32 k                                                       -- snapshot k arrived here
	        u8 3..8, u32 tick, u16 len, bytes                                  -- (v1.11) 3 = an intent we sent
	            (raw Protocol buffer), 4 = an order outcome (JSON, autoplay ledger), 5 = a decision (JSON);
	            (v1.12) 6 = the teacher's view (JSON: fronts, threats, geo), 7 = an order opened (JSON),
	            8 = match end (JSON). Spec: docs/data-collection-spec.md

	Load: loadstring(readfile("RoWorld/main.lua"))()
]]

local VERSION = "1.15-v3"
-- one copy per server (queue_on_teleport, a manual run or an autoexec loader may all load us);
-- set getgenv().__RW_FORCE = true to load again anyway
if getgenv().__RW_MAIN_JOB == game.JobId and getgenv().RoWorld and not getgenv().__RW_FORCE then
	print("[RoWorld] main.lua already running on this server - skipped (set getgenv().__RW_FORCE = true to reload)")
	return
end
getgenv().__RW_MAIN_JOB = game.JobId
getgenv().__RW_FORCE = nil
-- a second copy on the same server (a reload, or two loaders) replaces the first: the old copy saves its
-- recording and its loops end. 2026-11-16: two copies ran a whole match side by side - the second one deleted
-- the first one's snap_001 and took autoplay's decision records into a recording that never got a snapshot.
do
	local prev = rawget(getgenv(), "RoWorld")
	if type(prev) == "table" and type(prev.shutdown) == "function" then
		pcall(prev.shutdown, "reloaded")
	end
end
local GEN = (rawget(getgenv(), "__RW_MAIN_GEN") or 0) + 1
getgenv().__RW_MAIN_GEN = GEN
local function current()
	return getgenv().__RW_MAIN_GEN == GEN
end
print("[RoWorld] main.lua v" .. VERSION .. " starting")
local GUI_URL = "https://raw.githubusercontent.com/TheJellyfish1412/Workspace/refs/heads/main/guiV3.lua"
local SELF_PATH = "RoWorld/v3/main.lua"
local SELF_NAME = "v3/main.lua"            -- bridge: /lua/v3/main.lua
pcall(function() if makefolder and not isfolder("RoWorld/v3") then makefolder("RoWorld/v3") end end)
-- scripts come from the PC (Source/sim: python -m ai.bridge_server, GET /lua/<file>); a copy is kept in the
-- workspace and used when the PC does not answer
local SRC_URL = "http://192.168.1.34:8766/lua/"
local function fetch_script(name, path)
	local ok, src = pcall(function() return game:HttpGet(SRC_URL .. name) end)
	if ok and type(src) == "string" and #src > 1000 then
		pcall(writefile, path, src)
		return src
	end
	if isfile and isfile(path) then
		return readfile(path)
	end
	return nil
end
-- remote console (Source/rc.lua, PC: python -m ai.rc serve): the PC sends Luau to run here and reads its output.
-- Loaded first and in its own thread, so it works even when the rest of this script fails.
task.spawn(function()
	local ok, src = pcall(function() return game:HttpGet("http://192.168.1.34:8767/lua/rc.lua") end)
	if ok and type(src) == "string" and #src > 1000 then
		pcall(writefile, "RoWorld/v3/rc.lua", src)
	elseif isfile and isfile("RoWorld/v3/rc.lua") then
		src = readfile("RoWorld/v3/rc.lua")
	else
		return
	end
	local f = loadstring(src)
	if f then f() end
end)
local RECORD_ROOT = "RoWorldRecord"
local FLUSH_EVERY = 200 -- deltas per chunk file (~20 s of match)
local FLUSH_SECONDS = 30 -- also write at least this often, so a client crash loses little
local RESYNC_EVERY = 3000 -- ticks: ask for a fresh snapshot; the converter checks its replay against it

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local function rwlog(...)
	local L = rawget(getgenv(), "Log") or Log
	if type(L) == "table" or type(L) == "function" then
		pcall(L, "[RoWorld]", ...)
	end
end

-- reload this script after a teleport (joining a match moves us to another server)
if queue_on_teleport and not getgenv().__RW_QUEUED then
	getgenv().__RW_QUEUED = true
	pcall(queue_on_teleport, 'local ok, s = pcall(function() return game:HttpGet("' .. SRC_URL .. SELF_NAME .. '") end) '
		.. 'if ok and type(s) == "string" and #s > 1000 then pcall(writefile, "' .. SELF_PATH .. '", s) loadstring(s)() '
		.. 'else loadstring(readfile("' .. SELF_PATH .. '"))() end')
end

-- guiV3 returns two values: the UI builder and its helper table (save/load, webhook)
-- the UI library: from the PC (D:/MyFloder/Play/Lua/gui/guiV3.lua via the bridge server), else the workspace
-- copy, else GitHub
local gui_src = fetch_script("guiV3.lua", "RoWorld/v3/guiV3.lua")
if not gui_src then
	local okg, g = pcall(function() return game:HttpGet(GUI_URL) end)
	gui_src = okg and g or nil
end
local create, RFM = loadstring(gui_src)()
getgenv().RFManager = getgenv().RFManager or {}
local cfg = getgenv().RFManager
local pending_solo_webhook = getgenv().__RW_SOLO_FARM_WEBHOOK
if type(pending_solo_webhook) == "string" and pending_solo_webhook ~= ""
	and (type(cfg.RW_SoloFarmWebhook) ~= "string" or cfg.RW_SoloFarmWebhook == "") then
	cfg.RW_SoloFarmWebhook = pending_solo_webhook
	pcall(RFM.Store, RFM)
end
getgenv().__RW_SOLO_FARM_WEBHOOK = nil
-- version 3: strategy v1 plans; the version 2 model off (with RW_Model on it plays before play_strat)
local function v3_settings()
	local t = getgenv().RFManager
	for _, c in { cfg, t ~= cfg and t or nil } do
		if type(c) == "table" then
			c.RW_Strat, c.RW_Model, c.RW_ModelOnly = true, false, false
		end
	end
end
v3_settings()
task.spawn(function()
	for _ = 1, 60 do
		task.wait(1)
		v3_settings()
	end
end)

-- UI calls can fail from threads without UI permission (e.g. dashboard console code):
-- never let that stop the recorder or the loop
local function notify(title, text, secs)
	pcall(function() create:Notify(title, text, secs) end)
end
local function set_text(lbl, text)
	pcall(function() lbl:SetText(text) end)
end
-- record off by default too (owner 2026-11-22): the saved value from the old default (on) is reset once
if cfg.RW_Record == nil or cfg.RW_RecordDefaultOff == nil then
	cfg.RW_Record = false
	cfg.RW_RecordDefaultOff = true
	pcall(function() RFM:Store() end)
end
if cfg.RW_AutoFFA == nil then cfg.RW_AutoFFA = false end
if cfg.RW_JoinMode ~= "solo" and cfg.RW_JoinMode ~= "world" then cfg.RW_JoinMode = "world" end
if cfg.RW_SoloSpeed == nil then cfg.RW_SoloSpeed = false end
-- Solo against the game's bots: difficulty 0 Relaxed / 1 Standard / 2 Brutal (the title screen's chips), and
-- start the next Solo match by itself when one ends (Play again)
if tonumber(cfg.RW_SoloDifficulty) == nil then cfg.RW_SoloDifficulty = 1 end
if cfg.RW_SoloRegame == nil then cfg.RW_SoloRegame = true end
-- the version 3 plan model on the PC (script/bridge_v3.py /plan) picks the plans; the rule picks when the PC
-- does not answer
if cfg.RW_PlanModel == nil then cfg.RW_PlanModel = true end
-- auto play and auto join off by default (owner 2026-11-22: the owner plays and joins, the record keeps the
-- clicks). Until now the v3 loader forced auto play on and Training mode forced auto join on, and those forced
-- values got saved: reset them once, then the toggles rule.
if cfg.RW_AutoPlay == nil or cfg.RW_AutoPlayDefaultOff == nil then
	cfg.RW_AutoPlay = false
	cfg.RW_AutoPlayDefaultOff = true
	pcall(function() RFM:Store() end)
end
if cfg.RW_AutoFFADefaultOff == nil then
	cfg.RW_AutoFFA = false
	cfg.RW_AutoFFADefaultOff = true
	pcall(function() RFM:Store() end)
end
if cfg.RW_RequeueDelay == nil then cfg.RW_RequeueDelay = 8 end
if cfg.RW_LeaveOnDeath == nil then cfg.RW_LeaveOnDeath = true end -- don't sit out a lost match (recording ends there)
-- one switch for the capture loop: keep complete match records and requeue after each one;
-- Auto Play / model choice stay under their existing settings.
-- Retire the old combined training switch. Auto Record and Auto Join are now controlled separately.
if cfg.RW_TrainingMode ~= nil or cfg.RW_TrainingPrevLeave ~= nil then
	if cfg.RW_TrainingPrevLeave ~= nil then cfg.RW_LeaveOnDeath = cfg.RW_TrainingPrevLeave end
	cfg.RW_TrainingMode, cfg.RW_TrainingPrevLeave = nil, nil
	pcall(RFM.Store, RFM)
end
-- the policy model runs on the PC (Source/sim: python -m ai.bridge_server --model <pt>); autoplay sends its obs
-- there every decision (game:HttpGet) and the v2 teacher plays any decision the PC does not answer
if cfg.RW_Bridge == nil then cfg.RW_Bridge = "http://192.168.1.34:8766" end
if cfg.RW_Model == nil then cfg.RW_Model = true end
if cfg.RW_Sample == nil then cfg.RW_Sample = true end   -- play the PPO policy by sampling, as it trained
if cfg.RW_ModelOnly == nil then cfg.RW_ModelOnly = true end -- only the model decides; no teacher fallback
-- obs to the bridge in a game:HttpPost body (gzipped by the game, the bridge unpacks it; tested 2026-11-18), GET as fallback
if cfg.RW_BridgePost == nil then cfg.RW_BridgePost = "HttpPost" end
-- model play: no early surrender (the teacher's hopeless rule left at tick 967 with land and troops still
-- there, cutting the record); RW_LeaveOnDeath still leaves once we are eliminated
if cfg.RW_ModelOnly then cfg.RW_Surrender = false end

local function session()
	local ok, Main = pcall(function()
		local client = LocalPlayer:WaitForChild("PlayerScripts", 10):WaitForChild("AirfrontClient", 10)
		return require(client:WaitForChild("Main", 10))
	end)
	if ok and type(Main) == "table" then
		return Main.session
	end
	return nil
end

local function in_match(s)
	return s ~= nil and s.mode == 2 and s.state ~= nil
end

local function mkdirs(path)
	local acc = ""
	for seg in string.gmatch(path, "[^/]+") do
		acc = acc == "" and seg or (acc .. "/" .. seg)
		if not isfolder(acc) then
			makefolder(acc)
		end
	end
end

-- ===================================================================================
-- Recorder
-- ===================================================================================
local Rec = {
	on = false, dir = nil, deltas = 0, snaps = 0, bytes = 0, files = 0,
	chunk = {}, chunk_deltas = 0, started = 0, first_tick = nil, last_tick = nil, meta = nil,
}

local function write_meta(extra)
	if not Rec.dir then
		return
	end
	local m = Rec.meta or {}
	for k, v in pairs(extra or {}) do
		m[k] = v
	end
	m.updated_unix = os.time()
	m.deltas, m.snapshots, m.bytes, m.files, m.events = Rec.deltas, Rec.snaps, Rec.bytes, Rec.files, Rec.events or 0
	m.first_tick, m.last_tick = Rec.first_tick, Rec.last_tick
	Rec.meta = m
	pcall(writefile, Rec.dir .. "/meta.json", HttpService:JSONEncode(m))
end

local function flush()
	if not Rec.dir or #Rec.chunk == 0 then
		return
	end
	Rec.files += 1
	local data = table.concat(Rec.chunk)
	Rec.chunk = {}
	Rec.chunk_deltas = 0
	local ok, err = pcall(writefile, string.format("%s/deltas_%05d.bin", Rec.dir, Rec.files), data)
	if not ok then
		rwlog("chunk write failed", err)
	end
	write_meta()
end

local function on_snapshot(owner, buf)
	if not Rec.on then
		return
	end
	Rec.snaps += 1
	local s = buffer.tostring(buf)
	Rec.bytes += #s
	writefile(string.format("%s/snap_%03d_%d.bin", Rec.dir, Rec.snaps, owner), s)
	table.insert(Rec.chunk, string.pack("<BI4", 2, Rec.snaps))
	rwlog("snapshot", Rec.snaps, "owner", owner, #s, "bytes")
	write_meta()
end

-- extra records (tags 3/4/5, same layout so a reader can skip unknown ones): what we sent and decided
local function on_event(tag, tick, data)
	if not Rec.on or Rec.snaps == 0 then
		return
	end
	if #data > 65535 then
		data = string.sub(data, 1, 65535)
	end
	table.insert(Rec.chunk, string.pack("<BI4s2", tag, tick or 0, data))
	Rec.events = (Rec.events or 0) + 1
	Rec.bytes += #data + 7
end

local function on_delta(a, b)
	if not Rec.on or Rec.snaps == 0 then
		return -- deltas before the first snapshot can't be replayed
	end
	local sa = buffer.tostring(a)
	local sb = b and buffer.tostring(b) or nil
	table.insert(Rec.chunk, string.pack("<BI4I4", 1, #sa, sb and #sb or 0xFFFFFFFF) .. sa .. (sb or ""))
	Rec.deltas += 1
	Rec.chunk_deltas += 1
	Rec.bytes += #sa + (sb and #sb or 0) + 9
	if Rec.chunk_deltas >= FLUSH_EVERY then
		flush()
	end
end

-- defined below; install_hooks (session:leave_match etc.) needs it. Before v1.12 this was declared
-- after install_hooks, so the hooks called a nil global and a menu leave did not save the recording
local stop_recording
-- the session hooks are installed once per session and always call the copy of main.lua that runs now
-- (getgenv().__RW_REC_HOOKS, set by every copy), so a reload records into its own recording
getgenv().__RW_REC_HOOKS = {
	snapshot = function(owner, buf) return on_snapshot(owner, buf) end,
	delta = function(a, b) return on_delta(a, b) end,
	intent = function(tick, data) return on_event(3, tick, data) end,
	stop = function(why) if Rec.on then stop_recording(why) end end,
}
local function hooks()
	return rawget(getgenv(), "__RW_REC_HOOKS") or {}
end
local function install_hooks(s)
	if s == nil or rawget(s, "__rw_hooked2") then
		return
	end
	rawset(s, "__rw_hooked2", true)
	-- every way out of a match goes through session:leave_match (the pause menu SURRENDER /
	-- LEAVE MATCH button, the bot giving up, Auto FFA): save the recording first
	local orig_leave = s.leave_match
	s.leave_match = function(self, ...)
		local why = rawget(getgenv(), "__RW_LEAVE_REASON") or "left the match (menu)"
		getgenv().__RW_LEAVE_REASON = nil
		pcall(hooks().stop, why)
		return orig_leave(self, ...)
	end
	-- the other ways out (found 2026-11-14: a match ended with no end_reason): the server
	-- connection drops, or the server closes the match
	for name, why in { _on_server_lost = "server connection lost", _on_match_closed = "match closed by the server" } do
		local orig = s[name]
		if type(orig) == "function" then
			s[name] = function(self, ...)
				pcall(hooks().stop, why)
				return orig(self, ...)
			end
		end
	end
	-- our own commands, as sent (tag 3)
	local net = s.env and s.env.net
	local okp, Protocol = pcall(function()
		return require(ReplicatedStorage:WaitForChild("Airfront", 10).Net.Protocol)
	end)
	if net and okp and Protocol and not rawget(net, "__rw_rec_send2") then
		rawset(net, "__rw_rec_send2", true)
		local orig_send = net.send
		net.send = function(op, a, ...)
			if op == Protocol.OP.INTENT and typeof(a) == "buffer" then
				pcall(hooks().intent, s.state and s.state.tick or 0, buffer.tostring(a))
			end
			return orig_send(op, a, ...)
		end
	end
	local orig_snap, orig_delta = s._on_snapshot, s._on_delta
	s._on_snapshot = function(self, owner, buf, ...)
		if type(buf) == "buffer" then
			local ok, err = pcall(hooks().snapshot, owner, buf)
			if not ok then rwlog("record snapshot error", err) end
		end
		return orig_snap(self, owner, buf, ...)
	end
	s._on_delta = function(self, a, b, ...)
		if type(a) == "buffer" then
			local ok, err = pcall(hooks().delta, a, b)
			if not ok then rwlog("record delta error", err) end
		end
		return orig_delta(self, a, b, ...)
	end
end

-- Check each recording folder once. Old unfinished matches are removed, and the JSON ledger
-- records every checked folder so a restart never repeats or hides the cleanup decision.
local CLEANUP_LOG = RECORD_ROOT .. "/cleanup_checked.json"
local CLEANUP_AFTER = 600
local function load_cleanup_log()
	if isfile and isfile(CLEANUP_LOG) then
		local ok, data = pcall(function() return HttpService:JSONDecode(readfile(CLEANUP_LOG)) end)
		if ok and type(data) == "table" then return data end
	end
	return {}
end
local function save_cleanup_log(log)
	pcall(function() writefile(CLEANUP_LOG, HttpService:JSONEncode(log)) end)
end
local function close_unfinished()
	pcall(mkdirs, RECORD_ROOT)
	local ok, dirs = pcall(listfiles, RECORD_ROOT)
	if not ok or type(dirs) ~= "table" then
		local ledger = load_cleanup_log()
		ledger._scan_error = { checked_unix = os.time(), action = "list_failed" }
		save_cleanup_log(ledger)
		return 0, 0
	end
	local ledger, removed, kept = load_cleanup_log(), 0, 0
	for _, path in ipairs(dirs) do
		local normalized = tostring(path):gsub("\\", "/"):gsub("/+$", "")
		local name = normalized:match("([^/]+)$")
		local folder = RECORD_ROOT .. "/" .. tostring(name or "")
		if name and name ~= "cleanup_checked.json" and folder ~= Rec.dir and isfolder(folder) then
			local prior = ledger[name]
			if not prior or prior.action == "delete_failed" or prior.action == "active_recent" then
				local mp = folder .. "/meta.json"
				local meta
				if isfile(mp) then
					local okm, parsed = pcall(function() return HttpService:JSONDecode(readfile(mp)) end)
					if okm and type(parsed) == "table" then meta = parsed end
				end
				local last_activity = meta and (tonumber(meta.updated_unix) or tonumber(meta.started_unix)) or 0
				if not meta then
					ledger[name] = { checked_unix = os.time(), action = "missing_meta" }
				elseif last_activity <= 0 then
					ledger[name] = { checked_unix = os.time(), action = "no_timestamp" }
				elseif os.time() - last_activity >= CLEANUP_AFTER then
					local reason = tostring(meta.end_reason or "")
					local incomplete = meta.end_reason == nil or string.sub(reason, 1, 11) == "interrupted"
					local action = "complete"
					if incomplete then
						local okd = pcall(delfolder, folder)
						action = okd and "deleted_incomplete" or "delete_failed"
						if okd then removed += 1 end
					else
						kept += 1
					end
					ledger[name] = { checked_unix = os.time(), action = action, end_reason = meta.end_reason }
				else
					ledger[name] = { checked_unix = os.time(), action = "active_recent" }
				end
				save_cleanup_log(ledger)
			end
		end
	end
	if ledger._scan_error then ledger._scan_error = nil end
	save_cleanup_log(ledger)
	return removed, kept
end

-- what the bot plays with (autoplay.lua Bot.teacher) and what we have unlocked (session.inventory)
local Bot -- set once autoplay.lua is loaded (below)
local function teacher_info()
	local ok, t = pcall(function() return Bot and Bot.teacher and Bot.teacher() end)
	return ok and t or nil
end
local function own_unlocks(s)
	local list = {}
	pcall(function()
		for k, v in (s.inventory and s.inventory.unlocks) or {} do
			if v then
				table.insert(list, tostring(k))
			end
		end
	end)
	table.sort(list)
	return list
end

-- party (PARTY button, Session.lua): who came with us; owner ids filled in once autoplay matches them
-- (meta.party.owners, refreshed in the loop) so a record says which owners were party mates
local PARTY_FILE = "RoWorld/party.json"
-- in the lobby: save the party (in a match session.party.members is empty, seen 2026-11-16); autoplay reads it
local function save_party(s)
	pcall(function()
		local p = s and s.party
		if type(p) ~= "table" or type(p.members) ~= "table" or #p.members <= 1 then
			return
		end
		local members = {}
		for _, m in p.members do
			local pl = m.uid and Players:GetPlayerByUserId(m.uid)
			table.insert(members, { uid = m.uid, name = m.name, username = pl and pl.Name or nil, leader = m.leader == true })
		end
		local js = HttpService:JSONEncode({ t = os.time(), members = members })
		if js ~= rawget(getgenv(), "__RW_PARTY_JS") then
			getgenv().__RW_PARTY_JS = js
			writefile(PARTY_FILE, js)
		end
	end)
end
local function party_info(s)
	local ok, res = pcall(function()
		local p = s and s.party
		local members = {}
		if type(p) == "table" and type(p.members) == "table" and #p.members > 1 then
			for _, m in p.members do
				local pl = m.uid and Players:GetPlayerByUserId(m.uid)
				table.insert(members, { uid = m.uid, name = m.name, username = pl and pl.Name or nil, leader = m.leader == true })
			end
		elseif isfile(PARTY_FILE) then
			local saved = HttpService:JSONDecode(readfile(PARTY_FILE))
			if os.time() - (saved.t or 0) < 6 * 3600 then
				members = saved.members or {}
			end
		end
		if #members <= 1 then
			return nil
		end
		local owners = {}
		local B = getgenv().RoWorldBot
		for o in (B and B.party) or {} do
			table.insert(owners, o)
		end
		table.sort(owners)
		return { members = members, owners = owners }
	end)
	return ok and res or nil
end

local function start_recording()
	local s = session()
	if not in_match(s) then
		notify("Record", "Not in a match yet", 3)
		return false
	end
	if Rec.on then
		return true
	end
	pcall(close_unfinished)
	install_hooks(s)
	-- the folder name carries the observation the bot plays with (owner 2026-11-17: tell records apart)
	local okt, tag = pcall(function() return Bot and Bot.obs_tag and Bot.obs_tag() end)
	tag = (okt and type(tag) == "string") and tag or "unknown"
	Rec.obs_tag = tag
	Rec.dir = string.format("%s/%s_%s_%s", RECORD_ROOT, os.date("!%Y%m%d_%H%M%S"), string.sub(game.JobId, 1, 8), tag)
	mkdirs(Rec.dir)
	Rec.deltas, Rec.snaps, Rec.bytes, Rec.files, Rec.chunk, Rec.chunk_deltas = 0, 0, 0, 0, {}, 0
	Rec.first_tick, Rec.last_tick, Rec.meta = nil, nil, nil
	Rec.resync_tick, Rec.flushed_at = nil, os.clock()
	Rec.events = 0
	Rec.peak_tiles = 0
	Rec.started = os.time()
	Rec.on = true
	local st = s.state
	write_meta({
		version = VERSION, place = game.PlaceId, job = game.JobId, started_utc = os.date("!%Y-%m-%dT%H:%M:%SZ"), started_unix = os.time(),
		map_id = st.map_id, local_owner = st.local_owner, tick_at_start = st.tick, roblox_players = #Players:GetPlayers(),
		lobby = s.lobby and { kind = s.lobby.kind, stage = s.lobby.stage, players = s.lobby.players and #s.lobby.players } or nil,
		teacher = teacher_info(), unlocks = own_unlocks(s), spec = "docs/data-collection-spec.md",
		party = party_info(s), obs = Rec.obs_tag,
		-- Reinforcements need an Arsenal unlock; without it the bot never reinforces or combos
		can_reinforce = select(2, pcall(s.has_unlock, s, "reinforce")) == true,
	})
	-- ask the server for a fresh snapshot so the recording can be replayed from here
	s._resync_at = -1e9
	pcall(s._request_resync, s)
	rwlog("recording ->", Rec.dir)
	notify("Record", "Recording to " .. Rec.dir, 4)
	return true
end

local function final_state()
	local ok, res = pcall(function()
		local s = session()
		local st = s and s.state
		if not st then
			return nil
		end
		local me = st.owners[st.local_owner or 0]
		local rank = 1
		for _, o in st.owners do
			if o.alive and me and (o.tiles or 0) > (me.tiles or 0) then
				rank += 1
			end
		end
		return { tick = st.tick, phase = st.phase, winner = st.winner, over_reason = st.over_reason,
			me_alive = me and me.alive, me_tiles = me and me.tiles, me_rank = rank,
			me_troops = me and math.floor(me.troops or 0), me_gold = me and math.floor(me.gold or 0),
			me_peak_tiles = Rec.peak_tiles, killer = me and me.killer, local_owner = st.local_owner,
			can_reinforce = select(2, pcall(s.has_unlock, s, "reinforce")) == true }
	end)
	return ok and res or nil
end
stop_recording = function(reason)
	if not Rec.on then
		return
	end
	-- match end as the last record of the stream (tag 8), then close
	local fin = final_state() or {}
	fin.reason = reason or "manual"
	pcall(function()
		on_event(8, fin.tick or Rec.last_tick or 0, HttpService:JSONEncode(fin))
	end)
	Rec.on = false
	-- the session can still look "in match" for a moment after leaving: never restart in this one
	local s0 = session()
	Rec.stopped_state = s0 and s0.state
	Rec.last_tick = (final_state() or {}).tick or Rec.last_tick
	flush()
	local bot = nil
	pcall(function()
		local B = getgenv().RoWorldBot
		local ms = {}
		for k, v in (B and B.model_stats) or {} do ms[k] = { chosen = v.chosen, sent = v.sent } end
		bot = { bridge = cfg.RW_Bridge, model = B and B.model and (B.model.version or "local"), bridge_ok = B and B.bridge_ok,
			bridge_fail = B and B.bridge_fail, bridge_ms = B and B.bridge_ms, model_stats = ms, last = B and B.last,
			exec_refused = B and B.xw, nuke_why = B and B.nuke_why }
	end)
	write_meta({ ended_utc = os.date("!%Y-%m-%dT%H:%M:%SZ"), end_reason = reason or "manual", final = final_state(), bot = bot })
	print(string.format("[RoWorld] recording saved before %s: %s (%d deltas, %.1f MB)", tostring(reason),
		tostring(Rec.dir), Rec.deltas, Rec.bytes / 1e6))
	rwlog("recording stopped", reason, Rec.deltas, "deltas", Rec.bytes, "bytes")
	notify("Record", string.format("Saved %d deltas (%.1f MB)", Rec.deltas, Rec.bytes / 1e6), 5)
end

-- ===================================================================================
-- Auto play + remote spy: RoWorld/autoplay.lua (Source/autoplay.lua). Loading it again stops
-- the copy that was running, so this is safe to re-run.
-- ===================================================================================
local AUTOPLAY_PATH = "RoWorld/v3/autoplay.lua"   -- version 3: its own copies in RoWorld/v3/
local function load_autoplay()
	local src = fetch_script("autoplay.lua", AUTOPLAY_PATH)
	if not src then
		rwlog("autoplay.lua missing")
		return nil
	end
	local f, err = loadstring(src)
	if not f then
		rwlog("autoplay.lua compile error", err)
		return nil
	end
	local ok, bot = pcall(f)
	if not ok then
		rwlog("autoplay.lua error", bot)
		return nil
	end
	return bot
end
Bot = load_autoplay() or { last = "autoplay.lua not loaded", list = {}, decisions = 0, sent = 0, sent_by = {}, ack_by = {} }

-- ===================================================================================
-- UI
-- ===================================================================================
local win = create:Win("RoWorld", 11390492777)

-- Main: single source of truth for auto play, auto join, and the selected queue mode.
local lobby = win:Taps("Main")
local lb = lobby:newpage()
lb:Label("Match settings")
lb:Toggle("Auto play (includes auto spawn)", cfg.RW_AutoPlay, false, function(on)
	cfg.RW_AutoPlay = on
	pcall(RFM.Store, RFM)
end)
lb:Toggle("Auto join", cfg.RW_AutoFFA, false, function(on)
	cfg.RW_AutoFFA = on
	pcall(RFM.Store, RFM)
end)
lb:Drop("Mode", cfg.RW_JoinMode == "solo" and "Solo" or "World", {"World", "Solo"}, function(value)
	cfg.RW_JoinMode = string.lower(tostring(value))
	pcall(RFM.Store, RFM)
end)
local SOLO_DIFFS = { [0] = "Relaxed", [1] = "Standard", [2] = "Brutal" }   -- the title screen's chips
lb:Drop("Solo difficulty", SOLO_DIFFS[math.clamp(math.floor(tonumber(cfg.RW_SoloDifficulty) or 1), 0, 2)],
	{"Relaxed", "Standard", "Brutal"}, function(value)
	for d, name in SOLO_DIFFS do
		if name == tostring(value) then cfg.RW_SoloDifficulty = d end
	end
	pcall(RFM.Store, RFM)
end)
lb:Toggle("Solo: play again when a match ends", cfg.RW_SoloRegame, false, function(on)
	cfg.RW_SoloRegame = on
	pcall(RFM.Store, RFM)
end)
local SOLO_FARM_PATH = "RoWorld/v3/solo_brutal_claim_loop.lua"
local function stop_solo_farm()
	local g = getgenv()
	g.__RW_BRUTAL_CLAIM_STOP = true
	g.__RW_BRUTAL_DEFER_VICTORY = false
	local original = g.__RW_TERRITORY_ASSIGN_ORIGINAL
	if original and type(hookfunction) == "function" then
		local ok = pcall(function()
			local engine = require(game:GetService("ReplicatedStorage"):WaitForChild("Engine"))
			local territory = require(game:GetService("ReplicatedStorage").Engine.sim.Territory)
			hookfunction(territory.assign, original)
		end)
		if ok then
			g.__RW_TERRITORY_ASSIGN_HOOKED = nil
			g.__RW_TERRITORY_ASSIGN_ORIGINAL = nil
		end
	end
end
local function start_solo_farm()
	local src = fetch_script("solo_brutal_claim_loop.lua", SOLO_FARM_PATH)
	if not src then return false, "solo_brutal_claim_loop.lua was not found" end
	local chunk, compile_error = loadstring(src)
	if not chunk then return false, tostring(compile_error) end
	local ok, run_error = pcall(chunk)
	if not ok then return false, tostring(run_error) end
	return true
end
lb:Toggle("Plan model (PC bridge picks the plans)", cfg.RW_PlanModel, false, function(on)
	cfg.RW_PlanModel = on
	pcall(RFM.Store, RFM)
end)
local ffa_status = lb:Label("Auto join: off")
local plan_status = lb:Label("Plan model: -")
lb:Label("Auto spawn is handled automatically by Auto Play.")

-- Star: Solo Brutal farming and its result reporting.
local star_tab = win:Taps("Star")
local star_farm = star_tab:newpage()
star_farm:Label("Solo Brutal")
local solo_farm_status = star_farm:Label("Solo farm: off")
star_farm:Toggle("Auto farm: Solo Brutal", cfg.RW_SoloFarm, false, function(on)
	cfg.RW_SoloFarm = on
	if on then
		getgenv().__RW_BRUTAL_CLAIM_STOP = false
		local ok, err = start_solo_farm()
		if not ok then
			cfg.RW_SoloFarm = false
			notify("Solo farm", err, 5)
		end
	else
		stop_solo_farm()
	end
	pcall(RFM.Store, RFM)
	set_text(solo_farm_status, cfg.RW_SoloFarm and "Solo farm: running" or "Solo farm: off")
end)

local star_webhook = star_tab:newpage()
star_webhook:Label("Stars result report")
star_webhook:Toggle("Send Stars report to webhook", cfg.RW_SoloFarmWebhookEnabled == true, false, function(on)
	cfg.RW_SoloFarmWebhookEnabled = on
	pcall(RFM.Store, RFM)
end)
star_webhook:TextBox("Stars webhook URL", "Discord webhook URL", function(value)
	local url = tostring(value or ""):gsub("%s+$", "")
	if url:match("^https://discord%.com/api/webhooks/") then
		cfg.RW_SoloFarmWebhook = url
		pcall(RFM.Store, RFM)
		create:Notify("Solo farm", "Stars webhook saved", 4)
	else
		create:Notify("Solo farm", "Enter a Discord webhook URL", 4)
	end
end)
star_webhook:Label("Reports use the GUI v3 Webhook module.")

-- Record -------------------------------------------------------------------------------
local rec_tab = win:Taps("Record")
local rc = rec_tab:newpage()
local rec_status = rc:Label("Recorder: idle")
local rec_detail = rc:Label("-")
local rec_dir = rc:Label("Folder: -")
rc:Line()
rc:Toggle("Auto record every match", cfg.RW_Record, false, function(on)
	cfg.RW_Record = on
	pcall(RFM.Store, RFM)
end)
rc:Button("Start recording now", function()
	start_recording()
end)
rc:Button("Stop and save", function()
	stop_recording("manual")
end)
rc:Line()
rc:Label("Recording files")
local cleanup_status = rc:Label("Cleanup: waiting")
local record_list = {}
for i = 1, 8 do record_list[i] = rc:Label("-") end
local function refresh_record_list(run_cleanup)
	local removed = 0
	if run_cleanup then removed = close_unfinished() end
	local ok, paths = pcall(listfiles, RECORD_ROOT)
	local folders = {}
	if ok and type(paths) == "table" then
		for _, path in ipairs(paths) do
			local normalized = tostring(path):gsub("\\", "/"):gsub("/+$", "")
			local name = normalized:match("([^/]+)$")
			local folder = RECORD_ROOT .. "/" .. tostring(name or "")
			if name and name ~= "cleanup_checked.json" and folder ~= Rec.dir and isfolder(folder) then
				table.insert(folders, name)
			end
		end
	end
	table.sort(folders, function(a, b) return a > b end)
	for i, label in ipairs(record_list) do
		set_text(label, folders[i] and ("• " .. folders[i]) or "-")
	end
	local ledger, checked, deleted = load_cleanup_log(), 0, 0
	for name, item in pairs(ledger) do
		if name ~= "_scan_error" then
			checked += 1
			if item.action == "deleted_incomplete" then deleted += 1 end
		end
	end
	set_text(cleanup_status, string.format("Folders %d | checked %d | removed incomplete %d | this scan removed %d", #folders, checked, deleted, removed))
end
rc:Button("Refresh files + clean incomplete", function()
	refresh_record_list(true)
end)
rc:Label("Cleanup log: " .. CLEANUP_LOG)
refresh_record_list(true)
task.spawn(function()
	while current() do
		task.wait(60)
		if current() then pcall(refresh_record_list, true) end
	end
end)

-- Second page within Main: Solo speed and Auto Play tuning.
local pc = lobby:newpage()
pc:Label("Game and Auto Play options")
local play_status = pc:Label("Auto play: off")
local play_detail = pc:Label("-")
pc:Toggle("Accelerate game in Solo", cfg.RW_SoloSpeed, false, function(on)
	cfg.RW_SoloSpeed = on
	pcall(RFM.Store, RFM)
end)
pc:Slider("Requeue delay after a match (s)", false, false, 0, 60, cfg.RW_RequeueDelay, 1, nil, function(v)
	cfg.RW_RequeueDelay = tonumber(v) or cfg.RW_RequeueDelay
	pcall(RFM.Store, RFM)
end)
pc:Toggle("Leave when eliminated", cfg.RW_LeaveOnDeath, false, function(on)
	cfg.RW_LeaveOnDeath = on
	pcall(RFM.Store, RFM)
end)
pc:Slider("Keep at home while expanding (% of cap)", false, false, 10, 60, cfg.RW_Keep, 1, nil, function(v)
	cfg.RW_Keep = tonumber(v) or cfg.RW_Keep
	pcall(RFM.Store, RFM)
end)
pc:Slider("Combo attack size (%)", false, false, 50, 90, cfg.RW_Combo, 1, nil, function(v)
	cfg.RW_Combo = tonumber(v) or cfg.RW_Combo
	pcall(RFM.Store, RFM)
end)
pc:Toggle("Accept alliance requests", cfg.RW_AutoAlly, false, function(on)
	cfg.RW_AutoAlly = on
	pcall(RFM.Store, RFM)
end)
pc:Toggle("Ask strong neighbours for alliances / extend", cfg.RW_AskAlly ~= false, false, function(on)
	cfg.RW_AskAlly = on
	pcall(RFM.Store, RFM)
end)
pc:Toggle("Give up hopeless matches (leave to lobby)", cfg.RW_Surrender ~= false, false, function(on)
	cfg.RW_Surrender = on
	pcall(RFM.Store, RFM)
end)
local play_acks = pc:Label("server confirmed: -")
pc:Button("Reload autoplay.lua", function()
	Bot = load_autoplay() or Bot
end)
pc:Line()
pc:Label("Spawns, expands keeping some troops home, counters big")
pc:Label("attacks, uses attack+attack+reinforce, builds defense/")
pc:Label("city/port, boats out, accepts / asks / extends alliances.")
task.spawn(function()
	while current() do
		set_text(play_status, cfg.RW_AutoPlay and ("Auto play: " .. Bot.last) or "Auto play: off")
		local src = Bot.plan_src_n or {}
		set_text(plan_status, not cfg.RW_PlanModel and "Plan model: off (rule picks)"
			or string.format("Plan model: %s | picks model %d rule %d | %s ms%s",
				Bot.plan_live and Bot.plan_live.version or "not connected", src.model or 0, src.rule or 0,
				tostring(Bot.plan_ms or "-"), Bot.plan_err and (" | " .. Bot.plan_err) or ""))
		set_text(play_detail, string.format("tiles %d  decisions %d  intents %d", #Bot.list, Bot.decisions, Bot.sent))
		local parts = {}
		for k, v in Bot.ack_by or {} do
			table.insert(parts, k .. " " .. v)
		end
		table.sort(parts)
		set_text(play_acks, "server confirmed: " .. (#parts > 0 and table.concat(parts, ", ") or "-"))
		task.wait(1)
	end
end)

-- ===================================================================================
-- Background loop: status, auto record, auto FFA World
-- ===================================================================================
local over_since = nil
local last_join = 0
local solo_seen = false
local function solo_difficulty()
	return math.clamp(math.floor(tonumber(cfg.RW_SoloDifficulty) or 1), 0, 2)
end
-- start Solo the way the game's own buttons do (UI/UIRoot.lua): the title's Play Solo = ui:_on_play_solo(d),
-- Game Over's Play again = ui:_restart_solo(d). Both save the difficulty setting, use the selected map
-- (setting map_id, UIMaps.valid) and hop to a new server when this one is outdated (hop_solo). No game UI ->
-- session:start_solo(d, map_id) like Main.lua's fallback. Returns which path ran.
local function solo_start(restart)
	local d = solo_difficulty()
	local ok, M = pcall(function() return require(LocalPlayer.PlayerScripts.AirfrontClient.Main) end)
	local ui = ok and type(M) == "table" and M.ui or nil
	if ui and restart and type(ui._restart_solo) == "function" then
		if ui.over and type(ui.over.close) == "function" then pcall(ui.over.close, ui.over) end   -- Game Over panel
		ui._solo_msec = 0                    -- its 1.5 s guard against double clicks
		if pcall(ui._restart_solo, ui, d) then return "ui restart" end
	elseif ui and not restart and type(ui._on_play_solo) == "function" then
		ui._solo_msec = 0
		if pcall(ui._on_play_solo, ui, d) then return "ui play solo" end
	end
	local s = session()
	if not s then return "no session" end
	local map_id = nil
	pcall(function()
		local set = s:load_settings("ui")
		map_id = type(set) == "table" and set.map_id or nil
	end)
	pcall(s.start_solo, s, d, map_id or "world")
	return "session start_solo"
end
local function tick_once()
		local s = session()
		save_party(s)
		local st = s and s.state
		-- recorder bookkeeping
		if Rec.on and st then
			Rec.first_tick = Rec.first_tick or st.tick
			Rec.last_tick = st.tick
			-- recording can start before the match assigns our owner id: fill it in once known
			if Rec.meta and (Rec.meta.local_owner or 0) == 0 and (st.local_owner or 0) > 0 then
				Rec.meta.local_owner = st.local_owner
			end
			local me = st.owners[st.local_owner or 0]
			if me and (me.tiles or 0) > (Rec.peak_tiles or 0) then
				Rec.peak_tiles = me.tiles
			end
		end
		if Rec.on and st then
			-- party mates' owner ids are known only after autoplay matched their names in the match
			local pi = party_info(s)
			local n = pi and #pi.owners or 0
			if n ~= (Rec.party_owners_n or 0) then
				Rec.party_owners_n = n
				write_meta({ party = pi })
			end
			if os.clock() - (Rec.flushed_at or 0) >= FLUSH_SECONDS then
				Rec.flushed_at = os.clock()
				flush()
			end
			-- checkpoint: a server snapshot every RESYNC_EVERY ticks (same call the game uses itself)
			Rec.resync_tick = Rec.resync_tick or st.tick
			if st.tick - Rec.resync_tick >= RESYNC_EVERY and st.phase ~= 2 then
				Rec.resync_tick = st.tick
				s._resync_at = -1e9
				pcall(s._request_resync, s)
			end
		end
		if cfg.RW_Record and not Rec.on and in_match(s) and st.phase ~= 2 and st ~= Rec.stopped_state then
			start_recording()
		end
		if Rec.on and (not in_match(s) or (st and st.phase == 2)) then
			stop_recording(in_match(s) and "match over" or "left match")
			print("[RoWorld] recording saved: " .. tostring(Rec.dir) .. " (" .. Rec.deltas .. " deltas)")
		end
		set_text(rec_status, Rec.on and ("Recording  tick " .. tostring(Rec.last_tick)) or "Recorder: idle")
		set_text(rec_detail, string.format("deltas %d  snapshots %d  %.1f MB", Rec.deltas, Rec.snaps, Rec.bytes / 1e6))
		set_text(rec_dir, "Folder: " .. tostring(Rec.dir or "-"))

		-- Solo: the next match starts by itself when one ends (cfg.RW_SoloRegame, or Auto join in Solo mode)
		local solo_match = s ~= nil and s.mode == 1 and s.state ~= nil and s.state_mode == 1
		if solo_match then
			solo_seen = true
		end
		local regame = cfg.RW_SoloRegame or (cfg.RW_AutoFFA and cfg.RW_JoinMode == "solo")
		if s and regame and solo_match then
			local me = st.owners[st.local_owner or 0]
			local dead = st.phase == 1 and me ~= nil and me.spawned and not me.alive
			if st.phase == 2 or dead then
				over_since = over_since or os.clock()
				if os.clock() - over_since >= cfg.RW_RequeueDelay and os.clock() - last_join > 10 then
					over_since, last_join = nil, os.clock()
					getgenv().__RW_LEAVE_REASON = dead and "eliminated" or "match over"
					if Rec.on then stop_recording(getgenv().__RW_LEAVE_REASON) end
					local how = solo_start(true)
					rwlog("solo play again", SOLO_DIFFS[solo_difficulty()], how)
					set_text(ffa_status, "Solo: playing again (" .. SOLO_DIFFS[solo_difficulty()] .. ")")
				else
					set_text(ffa_status, "Solo: match over - next one soon")
				end
			else
				over_since = nil
				set_text(ffa_status, "Solo: in match (tick " .. tostring(st.tick) .. ", " .. SOLO_DIFFS[solo_difficulty()] .. ")")
			end
		elseif s and regame and solo_seen and Bot.left and s.mode == 0 and not s:is_building()
			and os.clock() - last_join > 15 then
			-- autoplay gave up a Solo match (surrender -> title): start the next one. Leaving by hand does not.
			solo_seen = false
			last_join = os.clock()
			local how = solo_start(false)
			rwlog("solo play again from the title", SOLO_DIFFS[solo_difficulty()], how)
			set_text(ffa_status, "Solo: starting (" .. SOLO_DIFFS[solo_difficulty()] .. ")")
		elseif cfg.RW_AutoFFA and s then
			if in_match(s) or solo_match then
				local me = st.owners[st.local_owner or 0]
				local dead = cfg.RW_LeaveOnDeath and st.phase == 1 and me ~= nil and me.spawned and not me.alive
				if st.phase == 2 or dead then
					over_since = over_since or os.clock()
					if os.clock() - over_since >= cfg.RW_RequeueDelay then
						over_since = nil
						getgenv().__RW_LEAVE_REASON = dead and "eliminated" or "match over"
						pcall(s.leave_match, s)
						print("[RoWorld] " .. (dead and "eliminated" or "match over") .. " - leaving, Auto join queues the next match")
						set_text(ffa_status, "Auto join: match over, leaving")
					else
						set_text(ffa_status, "Auto join: match over")
					end
				else
					set_text(ffa_status, "Auto join: in match (tick " .. tostring(st.tick) .. ")")
				end
			elseif cfg.RW_JoinMode == "solo" then
				if s.mode == 0 and not s:is_building() and os.clock() - last_join > 15 then
					last_join = os.clock()
					local how = solo_start(false)
					rwlog("auto join mode: solo", SOLO_DIFFS[solo_difficulty()], how)
					set_text(ffa_status, "Auto join Solo: starting (" .. SOLO_DIFFS[solo_difficulty()] .. ")")
				else
					set_text(ffa_status, "Auto join Solo: waiting")
				end
			else
				local pub = s.public or {}
				if pub.state == "idle" and os.clock() - last_join > 15 and s:multiplayer_available() then
					last_join = os.clock()
					pcall(s.join_public, s, "world")
					set_text(ffa_status, "Auto join World: joining")
					rwlog("auto join mode: world")
				else
					set_text(ffa_status, "Auto join World: " .. tostring(pub.state or "waiting"))
				end
			end
		else
			set_text(ffa_status, "Auto join: off")
		end
		-- GameSource Session._local_process multiplies solo simulation time by local_speed;
		-- multiplayer uses a fixed speed of 1. Reset immediately outside Solo.
		if s then
			local wanted_speed = cfg.RW_SoloSpeed and s.mode == 1 and 2 or 1
			if s.local_speed ~= nil and s.local_speed ~= wanted_speed then
				s.local_speed = wanted_speed
			end
		end
end
task.spawn(function()
	while current() do
		local ok, err = pcall(tick_once)
		if not ok then
			rwlog("loop error", err)
		end
		task.wait(1)
	end
end)

-- memory watch (the client crashed late in big matches, 2026-11-16): every 60 s the Lua heap and the
-- game's total memory, kept in the record's meta.json ("mem", last 240 samples) and printed
task.spawn(function()
	local stats = game:GetService("Stats")
	local samples = {}
	while current() do
		task.wait(60)
		pcall(function()
			local B = getgenv().RoWorldBot
			local st = B and B.st
			local row = { utc = os.date("!%H:%M:%S"), tick = st and st.tick or 0, lua_mb = math.floor(collectgarbage("count") / 1024 * 10) / 10,
				total_mb = math.floor(stats:GetTotalMemoryUsageMb()), tiles = st and st.owners[st.local_owner or 0] and st.owners[st.local_owner].tiles or 0,
				units = (function() local n = 0 for _ in (st and st.units or {}) do n += 1 end return n end)(),
				orders = B and B.orders and #B.orders or 0 }
			table.insert(samples, row)
			if #samples > 240 then table.remove(samples, 1) end
			print(string.format("[RoWorld] mem tick %d: lua %.1f MB, total %d MB, tiles %d, units %d, orders %d",
				row.tick, row.lua_mb, row.total_mb, row.tiles, row.units, row.orders))
			if Rec.on then write_meta({ mem = samples }) end
		end)
	end
end)

-- handle for the dashboard console / other scripts
-- any other way to another server (match closed by the server, a party pull): save first
pcall(function()
	LocalPlayer.OnTeleport:Connect(function(state)
		if state == Enum.TeleportState.Started and Rec.on and current() then
			pcall(stop_recording, "teleport")
		end
	end)
end)

getgenv().RoWorld = {
	version = VERSION, rec = Rec, cfg = cfg, bot = Bot,
	start = start_recording, stop = stop_recording, flush = flush,
	event = function(tag, tick, data) pcall(on_event, tag, tick, data) end,   -- autoplay: ledger / macros
	save_settings = function() return pcall(RFM.Store, RFM) end,
	webhook = function(url)
		if not cfg.RW_SoloFarmWebhookEnabled then return nil end
		local target = type(url) == "string" and url or cfg.RW_SoloFarmWebhook
		if type(target) ~= "string" or target == "" then return nil end
		return RFM.Webhook:create(target)
	end,
	gen = GEN,
	-- called by the next copy of main.lua on this server: save the recording, end the loops
	shutdown = function(why)
		stop_solo_farm()
		if Rec.on then
			pcall(stop_recording, why or "reloaded")
		end
		if current() then
			getgenv().__RW_MAIN_GEN = GEN + 1
		end
	end,
}

-- guiV3: toggles that start "on" only fire their callback after this is set
getgenv().Loaded = true
notify("RoWorld", "Loaded v" .. VERSION .. ". RightCtrl or the corner button hides the window.", 4)
rwlog("main.lua loaded", VERSION, "place", game.PlaceId, "in match", in_match(session()))
print(string.format("[RoWorld] main.lua v%s loaded - auto play %s, auto join %s, record %s", VERSION,
	tostring(cfg.RW_AutoPlay), tostring(cfg.RW_AutoFFA), tostring(cfg.RW_Record)))
