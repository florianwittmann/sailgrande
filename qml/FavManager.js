.pragma library

var favTags = null;
var favTag =""

function getFavTags() {
    return favTags;
}

function addFavTag(tag) {
    if(getIndexOfTag(tag)!==-1)
        return;

    favTags.push(tag);
}

function delFavTag(tag) {
    var idx = getIndexOfTag(tag);
    if (idx !== -1) {
        favTags.splice(idx, 1);
        if(favTags===null) favTags = [];
    }
}

function getIndexOfTag(tag) {
   for(var i=0; i<favTags.length; i++) {
       if(favTags[i]===tag) {
           return i;
       }
   }
   return -1;

}

