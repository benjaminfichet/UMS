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
	-- Paths
	local  home_xml_struct_path = @"C:\symbdrives\BSSTools_Drive\SpiritTools\General_Tools\bss_presets\struct_xml.ms"
	filein home_xml_struct_path


	-- ReturnCode
	local thisdir = (getFilenamePath(getThisScriptFilename()))
	filein (thisdir + @"../ReturnCode/ReturnCode.ms")  

)


--UMS.ms
(
	local thisdir = (getFilenamePath(getThisScriptFilename()))

	filein (thisdir + @"config.ms")                      -- user config overwrites the default
	filein (thisdir + @"libraries/models.ms")            -- load up the models
)


struct ReturnCode (ret, data, reason)


/* ------------------------------------------------------------
	==================== UMS DATASTORE ====================
   ------------------------------------------------------------ */
struct UMSDatastore (

	_db_identifier    = "UMS_DATASTORE.xml",
	_datastore_tag_id = "Datastore",
	_update_tag_id    = "Update",
	_updates_ext      = ".zip",
	_datastore_timeout= (3600*24), -- 3600sec/1h * 24h -- a day

	xml_doc       = undefined,
	xml_datastore = undefined,


	updates = undefined,

	fn dbgPrint str mode:"dts" = (format "[UMS-dts]  %" str),
	fn dirExists d  = ((dotNetClass "System.IO.Directory").Exists d),
	fn fileExists f = ((getfiles f).count != 0),
	fn getDatastorePath = (UMS_DATASTORE + _db_identifier),
	fn datastoreExists  = (fileExists (getDatastorePath())),



	fn need_update = (
		local ret = ReturnCode ret:(isKindof this.xml_doc XMLDocument)

		ret
	),


	fn createDatastoreFile continueWakeUp:false = (
		local ret = ReturnCode ret:(not (this.datastoreExists()))
		if ret.ret then (
			this.xml_doc = xmldocument()
			this.xml_doc.file = (getDatastorePath())
			this.xml_doc.loaded = true


			-- Root node
			this.xml_datastore = this.xml_doc.getnewnode this._datastore_tag_id
			this.xml_doc.appendnode this.xml_datastore

			this.xml_datastore.AddAttribute "datastore_time" (timestamp() as string)
			this.xml_doc.savexml()

			-- New empty node
			local newNode = this.xml_doc.getNewNode _update_tag_id					--Get a new Node
			xml_datastore.AppendNode newNode									    --Append a new Node
			newNode.AddAttribute "entity"   "init"
			newNode.AddAttribute "skinmod"  "init"
			newNode.AddAttribute "version"  "0"
			newNode.AddAttribute "filename" "init"
			
			-- XX
			this.xml_doc.savexml()

			-- ret
			ret.ret = true
		)
		ret
	),


	fn _qSort_Updates_byVersion a b = (
		local aver =  (a.version as integer)
		local bver =  (b.version as integer)
		if aver == undefined or bver == undefined then (throw "Unable to execute qsort's function, an item is undefined!")


		local ret  = 0
		if (aver < bver) then (ret = -1)
		if (bver > aver) then (ret = 1)
		
		ret
	),


	fn wake_up = (
		--(dbgPrint "UMSDatastore wakes up.." mode:"datastore")
		this.dbgPrint "UMSDatastore wakes up..\n" mode:"dbg"
		local ret = ReturnCode ret:((classof UMS_DATASTORE) == String) reason:"UMS_DATASTORE glob.var must be set as string!"
		if ret.ret then (

			-- Check that this is a valid directory
			ret.ret = dirExists UMS_DATASTORE
			if ret.ret then (
				ret.reason = "Valid datastore directory! ("+UMS_DATASTORE + ")"


				-- Look for the xml file defining the updates
				local fname = this.getDatastorePath()
				ret.ret = datastoreExists()


				-- Create datastore file if it aint exist
				if not ret.ret then (ret = this.createDatastoreFile())



				if ret.ret then (
					ret.reason = "Found datastore's db! ("+fname + ")"
					this.dbgPrint ("DTS file: "+fname+"\n") mode:"dbg" 

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

						-- updates
						this.updates = #()

						-- Xml
						this.xml_datastore = this.xml_doc.GetRootNode()

						-- Root node must be of type: _datastore_tag_id -- update
						ret.ret = _datastore_tag_id == this.xml_datastore.Tag
						if ret.ret then (
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

							this.dbgPrint ("Registered updates: "+(this.updates.count as string)+"\n") mode:"dbg" 

							--this.dbgPrint "UMSDatastore woke up!\n" mode:"dbg"
							--(dbgPrint ("Available updates: " + (update_xml_nodes.count as string)) mode:"datastore")
						)else(reason = "Invalid root node type!")
					)

				)else(ret.reason = "Datastore's db not found! ("+fname+")")
			)else(ret.reason = "Invalid datastore directory! ("+UMS_DATASTORE + ")")
		)
		if ret.ret then (this.dbgPrint "UMSDatastore woke up!\n" mode:"datastore") else (dbgPrint "Unable to wake up datastore!\n" mode:"datastore")
		
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

					local nodeSkinver = (request.getSkinVersion()).data as string
					dbgPrint "Node request validated!\n"
					dbgPrint ("Current skin version: " + nodeSkinver + "\n")

					-- Select updates matching the request
					-- At least the entity name must match!
					local ret_updates = for u in this.updates where         ((u.entity == request.node.name) and \
																			((u.skinmod as name) == (request.skinmod as name)) and \
																			((u.version as integer) > (nodeSkinver as integer))) collect u
					

					-- Cache the UMSNodeRequest in every update in ._node_request
					for i in ret_updates do (i._node_request = request) 

					-- Sort updates by versions from up to bottom
					qsort ret_updates _qSort_Updates_byVersion

					ret.ret = true
					ret.data = ret_updates
				)
			)
		)
		ret
	),

	-- Scan an recreate xml file
	fn reload_datastore force:false = (
		local ret = ReturnCode ret:false


		-- delete old db
		if (datastoreExists()) then (
			deleteFile (getDatastorePath())

			-- Recreate datastore
			this.createDatastoreFile()

			-- get available updates
			local available_updates = #()

			-- Search files!
			local srch_pattern = (UMS_DATASTORE + "*" + this._updates_ext)
			local pubFiles =  getFiles srch_pattern
			local pubs = #()
			for f in pubFiles do (
				local filename = getFilenameFile f -- "C:\Work\code\3ds\maxscript\ASU\tmp\GauvainF04A_Mdl_Hood_Skin_75054107.ini"
				local fsplit = filterString filename "_"


				local bEntityName = ""
				local endpos = fsplit.count-2
				for i=1 to endpos do (
					bEntityName+=fsplit[i]
					if i<endpos then (bEntityName += "_")
				)
				-- New empty node
				local newNode = this.xml_doc.getNewNode _update_tag_id					    --Get a new Node from xmldoc
				this.xml_datastore.AppendNode newNode									    --Append a new Node to xml_datastore

				newNode.AddAttribute "entity"   bEntityName
				newNode.AddAttribute "skinmod"  (fsplit[fsplit.count-1] as string)
				newNode.AddAttribute "version"  (fsplit[fsplit.count] as string)
				newNode.AddAttribute "filename" (filename + (getFilenameType (f)))
			)

			this.xml_doc.savexml()
		)
		ret
	),

	on create do (

	)
)


---ds = UMSDatastore()
---ds.wake_up()
---ds.reload_datastore()

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
			ret = UMSUpdate.validate()
			if ret.ret then (
				dbgPrint "Updatete request validated!\n"

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








--ums = UpdateMySkins()
--wokeup = ums.wake_up()

-- Reload datastore
--ums.reload_datastore()
--todoUpdate = undefined

/*if wokeup.ret then (
	--local upds = ums.list_updates()
	--print upds.data

	--print "Selecting an update.."
	local mnd = $ch_lewis_b00a_mdl_body
	local req = UMSNodeRequest node:mnd skinmod:#Skin
	--print req

	local rupdates = ums.list_updates request:req
	print (rupdates.data)

	todoUpdate = rupdates.data[1]
	if todoUpdate != undefined then (
		--format "Will upgrade to :%\n" todoUpdate
		--format "Using: %\n" todoUpdate._node_request
--
--
		--print (ums.upgrade todoUpdate)
	)
	
)*/




-- init ums
(
	--ums = UpdateMySkins()
	--wokeup = ums.wake_up()
)



-- UMS GUI ?
try(destroyDialog UpdateMySkinsRollout)catch()
rollout UpdateMySkinsRollout "UpdateMySkinsRollout" (
	
	
)
CreateDialog UpdateMySkinsRollout