-- Copyright (c) Jérémie N'gadi
--
-- All rights reserved.
--
-- Even if 'All rights reserved' is very clear :
--
--   You shall not use any piece of this software in a commercial product / service
--   You shall not resell this software
--   You shall not provide any facility to install this particular software in a commercial product / service
--   If you redistribute this software, you must link to ORIGINAL repository at https://github.com/ESX-Org/es_extended
--   This copyright should appear in every part of the project code

async = {}

function async.parallel(tasks, cb)

	if #tasks == 0 then
		cb({})
		return
	end

	local remaining = #tasks
	local results   = {}

	for i=1, #tasks, 1 do

		CreateThread(function()

			tasks[i](function(result)

				table.insert(results, result)

				remaining = remaining - 1;

				if remaining == 0 then
					cb(results)
				end

			end)

		end)

	end

end

function async.parallelLimit(tasks, limit, cb)

	if #tasks == 0 then
		cb({})
		return
	end

	local remaining = #tasks
	local running   = 0
	local queue     = {}
	local results   = {}

	for i=1, #tasks, 1 do
		table.insert(queue, tasks[i])
	end

	local function processQueue()

		if #queue == 0 then
			return
		end

		while running < limit and #queue > 0 do

			local task = table.remove(queue, 1)

			running = running + 1

			task(function(result)

				table.insert(results, result)

				remaining = remaining - 1;
				running   = running - 1

				if remaining == 0 then
					cb(results)
				end

			end)

		end

		CreateThread(processQueue)

	end

	processQueue()

end

function async.series(tasks, cb)
	async.parallelLimit(tasks, 1, cb)
end
