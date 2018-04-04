--app.ms

-- Liste les updates disponibles
-- updates =  UMS.listUpdates node:myNode skin:myNode[..]#Skin

-- Selectionne une ou la derniere version pour un upgrade
-- UMS.upgrade node:myNode skin:myNode version:optional

/*
========================================================
MMMMMMMMMMMM""MMMMM""M"""""`'"""`YMP""""""`MMMMMMMMMMMMM
MMMMMMMMMMMM  MMMMM  M  mm.  mm.  M  mmmmm..MMMMMMMMMMMM
MMMMMMMMMMMM  MMMMM  M  MMM  MMM  M.      `YMMMMMMMMMMMM
MMMMMMMMMMMM  MMMMM  M  MMM  MMM  MMMMMMM.  MMMMMMMMMMMM
MMMMMMMMMMMM  `MMM'  M  MMM  MMM  M. .MMM'  MMMMMMMMMMMM
MMMMMMMMMMMMb       dM  MMM  MMM  Mb.     .dMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
========================================================
                      UpdateMySkin!
========================================================
*/

-- dev switch 3rdlibs home/bss paths
global UMS_HOME_DEV = true


-- Source 3rd party modules
(
	local modo_3rd_libs = Modolize()
	modo_3rd_libs.init @"C:\symbdrives\BSSTools_Drive\SpiritTools"
	modo_3rd_libs.filein "General_Tools.bss_presets.struct_xml"

	-- ReturnCode
	local thisdir = (getFilenamePath(getThisScriptFilename()))
	filein (thisdir + @"../ReturnCode/ReturnCode.ms")  

)


--UMS.ms
(
	local ums_filein = Modolize()
	ums_filein.init (getFilenamePath(getThisScriptFilename()))

	ums_filein.filein "config"
	ums_filein.filein "libraries.models"
	ums_filein.filein "libraries.datastore"
)



/* ------------------------------------------------------------
	==================== UMS CORE MODULE ====================
   ------------------------------------------------------------ */
struct UpdateMySkins (

	datastore = undefined,

	fn dbgPrint str mode:"info" = (format "[UMS-%] %" mode str),
	fn wake_up = (
		this.dbgPrint "UMS wakes up..\n" mode:"core"
		local ret = this.datastore.wake_up()
		if ret.ret then (
			this.dbgPrint "UMS woke up!\n\n" mode:"core"
		)
		ret		
	),



	fn reload_datastore force:false = (
		local ret = this.datastore.reload_datastore force:force
		if ret.ret then (ret = this.datastore.wake_up())
		ret
	),


	fn list_updates request:undefined = (this.datastore.list_updates request:request),

	-- Takes an UMSUpdate
	fn upgrade up_request = (
		local ret = ReturnCode ret:(isKindOf up_request UMSUpdate) reason:"upgrade function takes an UMSUpdate as argument!"
		if ret.ret then (
			ret.reason = "" --- reset reason if we are here
			ret = up_request.validate()
			if ret.ret then (
				dbgPrint "Update request validated!\n"

				-- sub noderequest
				ret = up_request._node_request.validate()
				if ret.ret then (
					

				)
			)
		)
		ret
	),


	fn create_upgrade request = (
	),

	on create do (
		this.datastore = UMSDatastore()
	)
)








ums = UpdateMySkins()
wokeup = ums.wake_up()

-- Reload datastore
--ums.reload_datastore()
--todoUpdate = undefined
ret = undefined
if wokeup.ret then (
	--local upds = ums.list_updates()
	--print upds.data

	--print "Selecting an update.."
	local mnd = $ch_lewis_b00a_mdl_body
	local req = UMSNodeRequest node:mnd skinmod:#Skin
	--print req

	local rupdates = ums.list_updates request:req
	print (rupdates.data)


	-- there is update(s) available!
	if rupdates.data.count > 0 then (
		todoUpdate = rupdates.data[1]
		if todoUpdate != undefined then (
			--format "Will upgrade to :%\n" todoUpdate
			--format "Using: %\n" todoUpdate._node_request
	--
	--
			--ret = ums.upgrade todoUpdate
		)
	)
)
--ret