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

	_skin_version_key_id = "ums_skin_version",

	fn getSkinVersion = (
		local ret = ReturnCode ret:true
		local skn_ver = false
		local buff = getUserPropBuffer (this.node)
		local lns  = FilterString buff "\n" 
		for l in lns do (
			local toks = FilterString l "="
			if (trimLeft(trimRight(toks[1]))) == _skin_version_key_id then (skn_ver = trimLeft(trimRight(toks[2])))
		)
		if skn_ver != false then (ret.data = skn_ver)
		else(ret.data = 0)

		ret
	),

	fn validate = (
		local vnode     = (isValidNode node)
		local vskin     = false
		if vnode then (
			if skinmod == undefined then (this.skinmod = #Skin)
			local vskin     =  classof (node.modifiers[skinmod]) == Skin
		)
		ReturnCode ret:(vnode and vskin)
	),
	on create do ()
)



/* ------------------------------------------------------------
	==================== UMS UPDATE ====================
   ------------------------------------------------------------ */
struct UMSUpdate (
	entity   = undefined,
	version  = undefined,
	skinmod  = undefined,
	filename = undefined,

	_entity_tag_id   = "entity",
	_skinmod_tag_id  = "skinmod",
	_version_tag_id  = "version",
	_filename_tag_id = "filename",


	-- Used internally to bring back the original UMSNodeRequest to the upgrade function!
	_node_request    = undefined,


	fn _initFromXmlBloc xml = (
		this.entity   = xml.GetAttribute _entity_tag_id
		this.skinmod  = xml.GetAttribute _skinmod_tag_id
		this.version  = xml.GetAttribute _version_tag_id 
		this.filename = xml.GetAttribute _filename_tag_id

		(this.validate())
	),

	fn validate = (
		local ret = ReturnCode ret:true
		ret
	),
	on create do ()
)




/* ------------------------------------------------------------
	==================== UMS DATASTORE ====================
   ------------------------------------------------------------ */
struct UMSDatastore (


	_update_tag_id = "Update",

	xml_doc = undefined,
	updates = undefined,

	fn dbgPrint str mode:"info" = (format "[UmS-%] %\n" mode str),
	fn dirExists d  = ((dotNetClass "System.IO.Directory").Exists d),
	fn fileExists f = ((getfiles f).count != 0),


	fn _qSort_Updates_byVersion a b = (
		local aver =  (a.version as integer)
		local bver =  (b.version as integer)
		
		local ret  = 0
		if (aver < bver) then (ret = -1)
		if (bver > aver) then (ret = 1)
		
		ret
	),

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

						ret.ret = true
						ret.reason = "Initialized xml datastore!"
					)catch(
						ret.ret = false
						ret.reason = "Unable to process xml datastore! Corrupted ?"
					)

					-- Lasts initializations
					if ret.ret then (

						this.updates = #()
						local update_xml_nodes = this.xml_doc.GetNodesByTagName _update_tag_id
						for xmln in update_xml_nodes do (

							local upd = UMSUpdate()
							ret = upd._initFromXmlBloc xmln

							if ret.ret then (
								append this.updates upd
							)
						)

						-- Sort updates by versions from up to bottom
						qsort this.updates _qSort_Updates_byVersion


						(dbgPrint ("Available updates: " + (update_xml_nodes.count as string)) mode:"datastore")
					)

				)else(ret.reason = "Datastore's db not found! ("+fname+")")
			)else(ret.reason = "Invalid datastore directory! ("+UMS_DATASTORE + ")")
		)
		if ret.ret then (dbgPrint "UMSDatastore woke up!" mode:"datastore") else (dbgPrint "Unable to wake up datastore!" mode:"datastore")
		ret
	),

	-- Will list all the available update for the given noderequest
	-- if no request is given, all the updates will be yield
	fn list_updates request:undefined = (
		local ret = ReturnCode ret:(classof(request) == UndefinedClass or (isKindOf request UMSNodeRequest))
		if ret.ret then (

			-- Return all updates
			if request == undefined then (
				ret.ret  = true
				ret.data = this.updates
				ret.reason = "All updates returned!"

			)else( -- Return based on the request
				
					
				-- The request must validates itself by returning a ReturnCode
				ret = request.validate()
				if ret.ret then (	

					local nodeSkinver = (request.getSkinVersion()).data
					dbgPrint "Node request validated!"
					dbgPrint ("Current skin version: " + nodeSkinver)


					-- Select updates matching the request
					
					-- At least the entity name must match!
					local ret_updates_byname = for u in this.updates where  ((u.entity == request.node.name) and \
																			((u.skinmod as name) == (request.skinmod as name)) and \
																			((u.version as integer) > (nodeSkinver as integer))) collect u


					-- Cache the UMSNodeRequest in every update in ._node_request
					for i in ret_updates_byname do (i._node_request = request) 

					-- Sort updates by versions from up to bottom
					qsort ret_updates_byname _qSort_Updates_byVersion

					ret.ret = true
					ret.data = ret_updates_byname
				)
			)
		)
		ret
	),

	fn upgrade  = (

	),


	on create do (

	)
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

	fn list_updates request:undefined = (this.datastore.list_updates request:request),

	-- Takes an UMSUpdate
	fn upgrade up_request = (
	),



	fn create_upgrade request = (
		

	),

	on create do (
		this.datastore = UMSDatastore()
	)
)

todoUpdate = undefined


ums = UpdateMySkins()
wokeup = ums.wake_up()
if wokeup.ret then (
	--local upds = ums.list_updates()
	--print upds.data

	print "Selecting an update.."
	local mnd = $Ch_GauvainF04A_Mdl_Shoe
	local req = UMSNodeRequest node:mnd skinmod:#Skin
	--print req

	local rupdates = ums.list_updates request:req
	print (rupdates.data)


	todoUpdate = rupdates.data[1]
	format "Will upgrade to :%\n" todoUpdate



)
0


--new_update = ums.update()  -- Fetches new updates
--if new_update then (
--	ums.upgrade() -- version:4125412336 -- upgrade to latest or given update
--)

--z