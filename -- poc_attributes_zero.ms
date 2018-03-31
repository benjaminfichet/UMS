-- poc_attributes_zero.ms
-- Retrouver tout les parameters d'un perso sur le ctrl_params 
-- Pour générer un nouvel attribute holder definissant les valeurs neutres au passage du clean(ppcheck).
-- Utiliser la valeur de base comme default

-- funcs
fn dbgPrint str mode:"POCAttribs" = (format "[%] %\n" mode str)
fn getNodeByNameNonCaseSensitive nm = (
	local ret = false
	local nds = for i in objects where matchpattern (toLower(i.name)) pattern:(toLower(nm)) collect i
	if nds.count == 1 then (ret = nds[1])
	ret
)
fn getPersoName = (
	local ret = false
	local mymaster = 	for o in objects where matchpattern o.name pattern:"*_Master" collect o
	if mymaster.count == 1 then (mymaster = mymaster[1])
	ret = (filterstring mymaster.name "_")[2]
	ret
)




-- 1. find parameters to process
(
	local pname = getPersoName()
	if pname == false then (throw "Impossible de trouver un perso!")
	else(dbgPrint ("Found char: " + pname))

	-- We should have a correct char there
	local char_mstr = getNodeByNameNonCaseSensitive ("ch_" + pname + "_master")
	if char_mstr == false then (throw "Impossible de trouver un master pour: "+pname)
	else(dbgPrint ("Found master: " + char_mstr.name))

	-- Find ctrl params
	local ctrl_params = getNodeByNameNonCaseSensitive ("ch_" + pname + "_ctrl_params")
	if ctrl_params == false then (throw "Impossible de trouver un ctrl_params pour: "+pname)
	else(dbgPrint ("Found ctrl_params: " + ctrl_params.name))


	--2 . Find attributes
	local attrs_def = custAttributes.getDef ctrl_params.modifiers[1] 1
	if attrs_def != undefined then (
		local definitions = custAttributes.getDefData attrs_def

		local param_defs = definitions[1]
		local ui_def    = definitions[2]

		for pd in param_defs do (
			local valParamName = stf.substituteString pd.name " " "_"
			valParamName       = stf.substituteString valParamName "'" ""
			valParamName       = "Default_" + valParamName

			local valParamDef = ""
			print valParamName
		)
	)


)


/*
CAT_DEF = attributes Custom_Attributes Redefine:CAT_CurrentDef
(
	Parameters main rollout:params
	(
		'Param9' Type:# float UI:'Param9' Default:0.0
		'Param2' Type:# float UI:'Param2' Default:0.0
	)
	Rollout Params "Custom Attributes"
	(
		spinner 'Param9' "Param9" Width:160 Height:16 Align: # Center Type: # float Range:[0,100,0]
		spinner 'Param2' "Param2" Width:160 Height:16 Align: # Center Type: # float Range:[0,100,0]
	)
)
CustAttributes.add CAT_TargetObject CAT_DEF #Unique BaseObject : false*/