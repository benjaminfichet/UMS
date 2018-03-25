--qsortTests.ms



fn myqSortFunction v1 v2 =
(
	local d = distance [0,0] v1
	local dd = distance [0,0] v2
	case of
	(
		(d < dd): -1
		(d > dd): 1
		default: 0
	)
)
vals = #([10,10],[5,5],[4,4],[2,2],[1,1],[3,3])
qSort vals myqSortFunction
vals






struct SA (
	name,
	version
)

vs = #(
	(SA name:"Hello" version:"1"),
	(SA name:"BA" version:"54"),
	(SA name:"CD" version:"62"),
	(SA name:"EF" version:"777"),
	(SA name:"GH" version:"8888"),
	(SA name:"IJKL" version:"555555")
)

fn qSort_SA_byVersion a b = (
	local aver =  (a.version as integer)
	local bver =  (b.version as integer)
	
	local ret  = 0
	if (aver < bver) then (ret = -1)
	if (bver > aver) then (ret = 1)
	
	ret
)

qSort vs qSort_SA_byVersion
print vs