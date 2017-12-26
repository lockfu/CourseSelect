function opCheckCourse(url){
    var oids = document.getElementsByName("cids");
    var omasters = document.getElementsByName("master");

    var result=[];
    var mresult = [];

    var count=0;
    
    for(var i = 0;i<oids.length;i++){
      if (oids[i].checked) {

        if(omasters[i].checked){
          mresult[count] = 1;
        }else{
          mresult[count] = 0;
        }
        result[count++]=oids[i].value;
      }

    }

    if (result.length == 0) {
      alert("请选择课程");
    }else{
      window.location.href = url+"?cids="+result + "&ismass="+ mresult;
    }
  }

  function chbckick(){
    var ohdr = document.getElementById("hdr");
    var ocobjs = document.getElementsByName("cids");
    if(ohdr.checked){
      for(var i = 0;i<ocobjs.length;i++){
        if(ocobjs[i].checked) continue;
        ocobjs[i].checked = "checked";
      }
    }else{
       for(var i = 0;i<ocobjs.length;i++){
        if(ocobjs[i].checked) 
         ocobjs[i].checked = "";
      }
    }
  }

  function childchange(cobj){
    var ohdr = document.getElementById("hdr");
    var ocobjs = document.getElementsByName("cids"); 

    var count = 0;
    if(cobj.checked){
       for(var i = 0;i<ocobjs.length;i++){
        if(ocobjs[i].checked == false) break;
        count++;
      }
      if(count == ocobjs.length){
        ohdr.checked = "checked";
        count = 0;
      }
    }else{
      for(var i = 0;i<ocobjs.length;i++){
        if(ocobjs[i].checked == true) break;
        count++;
      }
      if(count == ocobjs.length){
        ohdr.checked = "";
        count = 0;
      }
    }
  }

function addCourse(url,cId,bId){
    var oM = document.getElementById(bId);

    var isMaster = 0;
    if(oM.checked){
      isMaster = 1;
    }
    // alert(isMaster);
    // var furl = url+"?id="+cId+"&isMas="isMaster;
    window.location.href = cId+"/"+url+"?id="+cId+"&isMas="+isMaster;
    // alert(furl);
}
