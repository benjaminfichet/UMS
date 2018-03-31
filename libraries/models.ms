/* ------------------------------------------------------------
	==================== UMS NODE REQUEST ====================
   ------------------------------------------------------------ */
struct UMSNodeRequest (
	node = undefined,
	skinmod = undefined,

	_skin_version_key_id = "ums_skin_version",
	_skin_default_name   = #Skin,

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
			if skinmod == undefined then (this.skinmod = this._skin_default_name)
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
