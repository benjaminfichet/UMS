# UMS
UpdateMySkin! aims to be a complete skin versioning, updating, .., library. VERY WIP.

The idea is to allow skins data to be updated in individual scenes from a central directory. 

If skins data are the only parts updated on a character rig, why not only update this part?
Eg: Riggers publishes skin updates in a central location. 
Animators's UMS fetch and apply the update(s) in the current scene.


```maxscript
-- Start UMS
ums = UpdateMySkins()

-- Reloads the datastore
ums.reload_datastore()

-- and tries to wake up
wokeup = ums.wake_up()
if wokeup.ret then (
	
	-- Lists all the updates
	local upds = ums.list_updates()
	print upds.data
  
  	-- Creates an update request from a given node
	local mnd = $Ch_XXX_Mdl_ZZZ
	local req = UMSNodeRequest node:mnd skinmod:#Skin

	-- Lists the updates available for the given node
	local rupdates = ums.list_updates request:req
	print (rupdates.data)
  
  	-- Prints the first (lastest) update 
	local todoUpdate = rupdates.data[1]
	format "Will upgrade to :%\n" todoUpdate
)
0
```
