# UMS
UpdateMySkin! aims to be a complete skin versioning, updating, .., library. VERY WIP
```maxscript

ums = UpdateMySkins()
ums.reload_datastore()
wokeup = ums.wake_up()
if wokeup.ret then (
	local upds = ums.list_updates()
	print upds.data
  
  
	local mnd = $Ch_XXX_Mdl_ZZZ
	local req = UMSNodeRequest node:mnd skinmod:#Skin


	local rupdates = ums.list_updates request:req
	print (rupdates.data)
  
	local todoUpdate = rupdates.data[1]
	format "Will upgrade to :%\n" todoUpdate
)
0
```
