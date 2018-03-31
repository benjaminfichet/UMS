struct UMSXml (
	fpath   = undefined,
	xml_doc = undefined,

	fn init xml_file = (






		
		this.xml_doc.file = xml_file
		xDoc.LoadXML "C:\\Temp.xml"								--Load XML from file
		rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!
	),

	fn getHandle = (this.xml_doc),
	on create do   (this.xml_doc = XMLDocument())		
)






testNewFile = True
testLoadFile = False

if testNewFile == True do(
	clearListener()
	
	--Create a new XML file
	xDoc = XMLDocument()							--Create a new XMLDocument
	xDoc.file = "C:\\Temp.xml"							--Set the file for the document, this would be set if we were using LoadXML() SEE BELOW
	xDoc.loaded = True									--Set loaded to True, this would be set if we were using LoadXML() SEE BELOW
	rNode = xDoc.getNewNode "RootNode"			--Create a new XMLNode THIS MUST BE CALLED!
	xDoc.AppendNode rNode							--Append the new node the XMLDocument
	rNode = xDoc.getRootNode()						--Get the Root Node of the document
	xDoc.SaveXML()										--Save the XML
	
	rNode.SetText "This is the Text"								--Set the node text
	rNode.AddAttribute "Attr" "Some Value"					--Add Attribute
	rNode.AddAttribute "Interesting" "Data"					--Add Attribute
	print (rNode.GetAttribute "Attr")								--Get Attribute Value
	print (rNode.GetAllAttributes())								--Get all of the attribute and there values as an array
	rNode.SetAttributeValue "Attr" "A new Value"			--Set an attribute Value
	rNode.AddAttribute "Del" "I am going to be deleted"	--Add Attribute
	rNode.DeleteAttribute "Del"									--Delete Attribute
	rNode.HasAttribute "Del"										--Test if the node Has the parsed attribute
	rNode.HasAttribute "Attr"										--Test if the node Has the parsed attribute
	
	newNode = xDoc.getNewNode "NewNode"					--Get a new Node
	rNode.AppendNode newNode									--Append a new Node
	newNode.SetText "I am a new Node"						--Set the New Node text
	
	
	newNode = xDoc.getNewNode "SpecialNode" 			--Create a new Node
	rNode.AppendNode newNode									--Append a new Node
	
	childs = rNode.GetChildren() 									--Get All of the Nodes Children
	print childs	
	
	rNode.DeleteChild newNode									--Delete Child
	xDoc.SaveXML()													--Save XML
	xDoc.PrettySaveXML()											--Saves well formed XML
	
)--End If


	--Load XML from File
if testLoadFile == True do(
	xDoc = XMLDocument()										--Create an XMLDcoument
	xDoc.LoadXML "C:\\Temp.xml"								--Load XML from file
	rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!
	
	rNode.SetAttributeValue "Attr" "Now I have been loaded"
	xDoc.SaveXML()
	
)--End If