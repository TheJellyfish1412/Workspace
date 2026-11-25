-- Solo loop: start Brutal -> auto-spawn -> wait for protection to end ->
-- claim free land -> wait for game over -> restart Brutal.
-- Run once from the title screen or during a Solo match. Stop with:
-- getgenv().__RW_BRUTAL_CLAIM_STOP = true

local G = getgenv()
G.__RW_BRUTAL_CLAIM_GEN = (G.__RW_BRUTAL_CLAIM_GEN or 0) + 1
local GEN = G.__RW_BRUTAL_CLAIM_GEN
G.__RW_BRUTAL_CLAIM_STOP = false

local Players = game:GetService("Players")
local player = Players.LocalPlayer
assert(player, "LocalPlayer is not available")
local client = player:WaitForChild("PlayerScripts"):WaitForChild("AirfrontClient")
local Main = require(client:WaitForChild("Main"))
local session = Main.session
local ui = Main.ui
assert(session, "Airfront session is unavailable")
local PROTECTION_TICKS = 1200 -- Brutal human-grace base: 120 s at 10 simulation ticks/s.
local SOLO_SPEED = 4
local original_speed = session.local_speed or 1

local function active()
	return G.__RW_BRUTAL_CLAIM_GEN == GEN and not G.__RW_BRUTAL_CLAIM_STOP
end

local function start_brutal(restart)
	if session.mode == 1 and session.local_speed ~= nil then
		session.local_speed = SOLO_SPEED
	end
	if ui then
		if restart and type(ui._restart_solo) == "function" then
			pcall(function() if ui.over and ui.over.close then ui.over:close() end end)
			ui._solo_msec = 0
			local ok = pcall(ui._restart_solo, ui, 2) -- 2 = Brutal
			if ok then return end
		elseif not restart and type(ui._on_play_solo) == "function" then
			ui._solo_msec = 0
			local ok = pcall(ui._on_play_solo, ui, 2) -- 2 = Brutal
			if ok then return end
		end
	end
	if type(session.start_solo) == "function" then
		local ok, settings = pcall(session.load_settings, session, "ui")
		local map_id = ok and type(settings) == "table" and settings.map_id or "world"
		session:start_solo(2, map_id)
	else
		error("Could not find Solo start/restart function")
	end
end

local function get_sim(state)
	local function valid(candidate)
		return type(candidate) == "table"
			and type(candidate.set_owner) == "function"
			and candidate.owner and candidate.o_tiles and candidate.o_kind
			and candidate.o_alive and candidate.map
	end
	local candidates = { state, session.sim, session._sim, session.simulator,
		session.simulation, session.sim_state, session._local_sim }
	for _, candidate in candidates do if valid(candidate) then return candidate end end
	-- Some client builds keep the local Sim off the public Session fields. In
	-- the executor, search existing Lua objects for its distinctive state shape.
	local scan = rawget(G, "getgc") or getgc
	if type(scan) == "function" then
		local ok, objects = pcall(scan, true)
		if ok and type(objects) == "table" then
			for _, candidate in objects do
				if valid(candidate) and (candidate.owner == state.owner or candidate.map == state.map) then
					return candidate
				end
			end
		end
	end
	return nil
end

local function choose_spawn(state)
	local map = state.map
	assert(map and map.land_list and map.land_count, "Map land list is unavailable for spawn")
	local candidates = {}
	for i = 0, map.land_count - 1 do
		local tile = buffer.readi32(map.land_list, i * 4)
		if buffer.readu8(map.terrain, tile) == 2 and buffer.readi32(state.owner, tile * 4) == 0 then
			candidates[#candidates + 1] = tile
		end
	end
	assert(#candidates > 0, "No free plains tile found for spawn")
	return candidates[math.random(1, #candidates)]
end

local function spawn_and_wait_protection()
	local sent_tile
	while active() do
		local state = session.state
		if session.mode == 1 and session.local_speed ~= nil and session.local_speed ~= SOLO_SPEED then
			session.local_speed = SOLO_SPEED
		end
		if session.mode == 1 and state and state.phase == 2 then return false end
		if session.mode == 1 and state and state.phase == 0 and (state.local_owner or 0) > 0 then
			local info = state.owners[state.local_owner]
			if info and info.spawned then break end
			if type(session.send_intent) ~= "function" then error("session.send_intent is unavailable") end
			if not sent_tile then sent_tile = choose_spawn(state) end
			local ok = pcall(session.send_intent, session, { type = "spawn", tile = sent_tile })
			if not ok then sent_tile = nil end -- repick if the request was rejected
		elseif session.mode == 1 and state and state.phase == 1 then
			break -- already past protection
		end
		task.wait(0.5)
	end
	if not active() then return false end

	-- Wait until the spawn/protection phase ends (phase 1 = playing).
	while active() do
		local state = session.state
		if session.mode == 1 and state and state.phase == 1 then return true end
		if session.mode ~= 1 or not state then return false end
		task.wait(0.5)
	end
	return false
end

local function wait_brutal_protection()
	local state = session.state
	assert(state and state.phase == 1, "Match left the playing phase before protection wait")
	local sim = get_sim(state)
	local function current_tick()
		sim = sim or get_sim(session.state)
		local live_sim = sim
		return (live_sim and live_sim.tick) or (session.state and session.state.tick) or state.tick
	end
	local until_tick = current_tick() + PROTECTION_TICKS
	local owner = state.local_owner
	local old_shield_until
	if sim and sim.o_shield_until and owner and owner > 0 then
		old_shield_until = sim.o_shield_until[owner] or 0
		-- The Solo AI checks this same shield before attacking. Keep it active
		-- through the protection wait, then restore the previous expiry.
		sim.o_shield_until[owner] = math.max(old_shield_until, until_tick + 1)
	else
		warn("[SoloBrutalLoop] Could not access Solo shield timer; using the game's normal protection only")
	end
	print(string.format("[SoloBrutalLoop] Brutal protection: waiting %d simulation ticks (2 minutes)", PROTECTION_TICKS))
	while active() do
		state = session.state
		if session.mode ~= 1 or not state or state.phase ~= 1 then break end
		if session.local_speed ~= nil and session.local_speed ~= SOLO_SPEED then
			session.local_speed = SOLO_SPEED
		end
		if sim and sim.o_shield_until and owner and owner > 0 then
			sim.o_shield_until[owner] = math.max(sim.o_shield_until[owner] or 0, until_tick + 1)
		end
		local tick = current_tick()
		if tick >= until_tick then
			if old_shield_until ~= nil then
				sim.o_shield_until[owner] = math.max(old_shield_until, tick)
			end
			return true
		end
		task.wait(0.5)
	end
	if old_shield_until ~= nil and sim and sim.o_shield_until and owner and owner > 0 then
		sim.o_shield_until[owner] = math.max(old_shield_until, (session.state and session.state.tick) or 0)
	end
	return false
end

local function visible_star_text()
	local gui = player:FindFirstChildOfClass("PlayerGui")
	if not gui then return {} end
	local found = {}
	for _, object in gui:GetDescendants() do
		if (object:IsA("TextLabel") or object:IsA("TextButton")) and object.Visible then
			local visible = true
			local parent = object.Parent
			while parent and parent ~= gui do
				if parent:IsA("GuiObject") and not parent.Visible then
					visible = false
					break
				end
				parent = parent.Parent
			end
			local text = tostring(object.Text or "")
			if visible and text ~= "" and (string.find(string.lower(text), "star", 1, true)
				or string.find(text, "★", 1, true) or string.match(text, "%+%s*[%d,]+")) then
				table.insert(found, text:gsub("\n", " "))
			end
		end
	end
	return found
end

local function print_star_award()
	-- Let the game-over reward panel finish appearing/animating.
	local deadline = os.clock() + 2
	while active() and os.clock() < deadline do task.wait(0.1) end
	local lines = visible_star_text()
	if #lines == 0 then
		print("[SoloBrutalLoop] No visible star-award text found in the result UI")
		return
	end
	local award_lines = {}
	for _, line in lines do
		if string.match(line, "%+%s*[%d,]+") then
			table.insert(award_lines, line)
		end
	end
	if #award_lines == 0 then award_lines = lines end
	print("[SoloBrutalLoop] Stars at game end: " .. table.concat(award_lines, " | "))
end

local function claim_free()
	local state = session.state
	local owner = state and state.local_owner
	assert(owner and owner > 0, "local_owner is not assigned")
	local sim = get_sim(state)
	assert(sim, "Could not locate local Solo Sim (set_owner/o_kind/o_alive); claim step did not run")
	local map = sim.map or state.map
	assert(map and map.land_list and map.land_count, "Map land list is unavailable")
	local count = 0
	print("[SoloBrutalLoop] Claim step started")
	for i = 0, map.land_count - 1 do
		if not active() then break end
		if session.local_speed ~= nil and session.local_speed ~= SOLO_SPEED then
			session.local_speed = SOLO_SPEED
		end
		local tile = buffer.readi32(map.land_list, i * 4)
		if buffer.readi32(sim.owner, tile * 4) == 0 then
			sim:set_owner(tile, owner)
			count += 1
		end
	end
	print(string.format("[SoloBrutalLoop] Claimed %d free tiles", count))
end

task.spawn(function()
	local ok, err = pcall(function()
		if session.mode ~= 1 or not session.state then
			print("[SoloBrutalLoop] Starting Brutal Solo")
			start_brutal(false)
		end
		while active() do
			if session.mode == 1 and session.local_speed ~= nil then
				session.local_speed = SOLO_SPEED
			end
			if not spawn_and_wait_protection() then break end
			if not wait_brutal_protection() then break end
			if not active() then break end
			claim_free()
			print("[SoloBrutalLoop] Waiting for game over")
			while active() do
				local state = session.state
				if session.mode ~= 1 or not state then break end
				if state.phase == 2 then break end
				task.wait(0.5)
			end
			if not active() then break end
			if session.mode == 1 and session.state and session.state.phase == 2 then
				print_star_award()
				if not active() then break end
				print("[SoloBrutalLoop] Game over; restarting Brutal Solo")
				start_brutal(true)
				local deadline = os.clock() + 30
				repeat
					task.wait(0.5)
				until not active() or os.clock() >= deadline
					or (session.mode == 1 and session.state and session.state.phase == 0)
				if active() and (session.mode ~= 1 or not session.state or session.state.phase ~= 0) then
					error("Brutal Solo restart did not enter the spawn phase within 30 seconds")
				end
			else
				break
			end
		end
	end)
	if session.local_speed ~= nil then
		session.local_speed = original_speed
	end
	if not ok then warn("[SoloBrutalLoop] Stopped: " .. tostring(err)) end
end)

print("[SoloBrutalLoop] Running. Set getgenv().__RW_BRUTAL_CLAIM_STOP = true to stop.")
