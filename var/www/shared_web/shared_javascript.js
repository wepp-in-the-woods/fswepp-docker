function checkUncheckSome(controller,theElements) {
	//Programmed by Shawn Olson
	//Copyright (c) 2006-2007
	//Updated on August 12, 2007
	//Permission to use this function provided that it always includes this credit text
	//  https://www.shawnolson.net
	//Find more JavaScripts at https://www.shawnolson.net/topics/Javascript/

	//theElements is an array of objects designated as a comma separated list of their IDs
	//If an element in theElements is not a checkbox, then it is assumed
	//that the function is recursive for that object and will check/uncheck
	//all checkboxes contained in that element

     var formElements = theElements.split(',');
	 var theController = document.getElementById(controller);
	 for(var z=0; z<formElements.length;z++){
		theItem = document.getElementById(formElements[z]);
		if(theItem.type){
			if (theItem.type=='checkbox') {
				theItem.checked=theController.checked;
			}
		} else {
	  	  theInputs = theItem.getElementsByTagName('input');
			for(var y=0; y<theInputs.length; y++){
				if(theInputs[y].type == 'checkbox' && theInputs[y].id != theController.id){
					theInputs[y].checked = theController.checked;
				}
			}
		}
    }
}

//used on "species" page, "future" page to show/hide divs and then save them in the event that user navigates away from page and back again
function scan(){
	var inputElements = document.getElementsByTagName('input');
	for(var i=0; i<inputElements.length; i++){
		if( inputElements[i].getAttribute('type') == 'radio' && inputElements[i].className == 'scanMe' ){
			var div = document.getElementById( inputElements[i].getAttribute('divId') );
			div.style.display = (inputElements[i].checked) ? 'block' : 'none';
		}
	}
	var optionElements = document.getElementsByTagName('option');
	for(var i=0; i<optionElements.length; i++){
		if( optionElements[i].className == 'scanMe' ){
			var div = document.getElementById( optionElements[i].getAttribute('divId') );
			var selectedOption = optionElements[i].parentNode[optionElements[i].parentNode.selectedIndex];
			div.style.display = (selectedOption == optionElements[i]) ? 'block' : 'none';
		}
	}
	return false;
}


//added for Safari and Google Chrome - other date script is not showing for them with this particular server set-up 
function showLastModified() {
var out = document.getElementById('lastModified');
var d = new Date();
if (d.toLocaleDateString) {
out.innerHTML = d.toLocaleDateString(document.lastModified);
}
else {
out.innerHTML = document.lastModified;
}
}
