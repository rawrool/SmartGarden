function repeat() {
    if (document.getElementById("moreTimes").checked) {
        var nDiv = document.createElement("DIV");
        var nInput = document.createElement("INPUT");
        var breakE = document.createElement("BR");

        nDiv.setAttribute("class", "col-sm-6");

        nInput.setAttribute("id", "datetimepicker2");
        nInput.setAttribute("type", "text");
        nInput.setAttribute("name", "startT2");
        nInput.setAttribute("class", "form-control");
        nInput.setAttribute("onClick", "setDate()");

        nInput.appendChild(breakE);
        nDiv.appendChild(nInput);
        document.getElementById("moreChecks").appendChild(nDiv);
    }
    else{
        var node = document.getElementById("moreChecks");

        while(node.firstChild){
            node.removeChild(node.firstChild);
        }
    }

    setDate();
}

function setDate(){
    $('#datetimepicker2').datetimepicker({
        format: 'LT'
    });
}