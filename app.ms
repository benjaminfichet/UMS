--app.ms


-- Liste les updates disponibles
-- updates =  UMS.listUpdates node:myNode skin:myNode[..]#Skin

-- Selectionne une ou la derniere version pour un upgrade
-- UMS.upgrade node:myNode skin:myNode version:optional




-- Source 3rd party modules
(
	local xml_lib_path = @"C:\symbdrives\BSSTools_Drive\SpiritTools\General_Tools\bss_presets\struct_xml.ms"
	filein xml_lib_path
)


--UMS.ms
(
	local thisdir = (getFilenamePath(getThisScriptFilename()))

	-- Include the configs
	filein (thisdir + @"config.ms")            -- user config overwrites the default
)


struct ReturnCode (ret, data, reason)








/* ------------------------------------------------------------
	==================== UMS NODE REQUEST ====================
   ------------------------------------------------------------ */
struct UMSNodeRequest (
	node = undefined,
	skinmod = undefined,

	fn validate = (
		local vnode     = (isValidNode node)
		local vskin     = ((classof skinmod) == Skin)
		local vsameNode = ((refs.dependentNodes skinmod)[1] == node)

		(ReturnCode ret:(vnode and vskin and vsameNode))
	),
	on create do ()
)






/* ------------------------------------------------------------
	==================== UMS DATASTORE ====================
   ------------------------------------------------------------ */
struct UMSDatastore (

	xml_doc = undefined,

	fn dbgPrint str mode:"info" = (format "[UmS-%] %\n" mode str),
	fn dirExists d  = ((dotNetClass "System.IO.Directory").Exists d),
	fn fileExists f = ((getfiles f).count != 0),

	fn wake_up = (
		--(dbgPrint "UMSDatastore wakes up.." mode:"datastore")
		local ret = ReturnCode ret:((classof UMS_DATASTORE) == String) reason:"UMS_DATASTORE glob.var must be set as string!"
		if ret.ret then (

			-- Check that this is a valid directory
			ret.ret = dirExists UMS_DATASTORE
			if ret.ret then (
				ret.reason = "Valid datastore directory! ("+UMS_DATASTORE + ")"


				-- Look for the xml file defining the updates
				local fname = UMS_DATASTORE + "UMS_DATASTORE.xml"
				ret.ret = fileExists fname

				if ret.ret then (
					ret.reason = "Found datastore's db! ("+fname + ")"

					try(
						-- Initializing the xml_doc
						this.xml_doc = XMLDocument()
						this.xml_doc.LoadXML fname

						local nds = this.xml_doc.GetNodesByTagName "Update"
						(dbgPrint ("Available updates: " + (nds.count as string)) mode:"datastore")
						ret.ret = true
						ret.reason = "Initialized xml datastore!"
					)catch(
						ret.ret = false
						ret.reason = "Unable to process xml datastore! Corrupted ?"
					)

				)else(ret.reason = "Datastore's db not found! ("+fname+")")
			)else(ret.reason = "Invalid datastore directory! ("+UMS_DATASTORE + ")")
		)
		if ret.ret then (dbgPrint "UMSDatastore woke up!" mode:"datastore") else (dbgPrint "Unable to wake up datastore!" mode:"datastore")
		ret
	),







	on create do ()
)









/* ------------------------------------------------------------
	==================== UMS CORE MODULE ====================
   ------------------------------------------------------------ */
struct UpdateMySkins (

	datastore = undefined,

	fn dbgPrint str mode:"info" = (format "[UmS-%] %\n" mode str),
	fn wake_up = (
		dbgPrint ("Waking up UMS..")
		local ret = this.datastore.wake_up()
		if ret.ret then (
			dbgPrint ("Datastore's alive!")






			dbgPrint ("UMS is alive!")
		)
		ret		
	),

	fn update_data = (
		dbgPrint "Updating database.."
		true
	),

	fn list_updates = (

	),

	fn upgrade = (
		dbgPrint "Upgrade.."
		true
	),
	
	on create do (
		this.datastore = UMSDatastore()
	)
)









ums = UpdateMySkins()
wokeup = ums.wake_up()
if wokeup.ret then (


)
print wokeup

0


--new_update = ums.update()  -- Fetches new updates
--if new_update then (
--	ums.upgrade() -- version:4125412336 -- upgrade to latest or given update
--)

--z