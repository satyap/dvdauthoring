var prefix='video';

function closeblind() {
    this.onclick=openblind;
    Effect.BlindUp(prefix + this.id);
    //document.getElementById('video'+this.id).style.display='none';
}

function openblind() {
    this.onclick=closeblind;
    //document.getElementById('video'+this.id).style.display='block';
    Effect.BlindDown(prefix + this.id);
}

function initblinds() {
    var bl=document.getElementsByTagName('div');
    var i;
    var vid;
    for(i=0;i<bl.length;i++) {
        if(bl[i].className=='vidgroup') {
            vid=document.getElementById(prefix + bl[i].id);
            vid.style.display="none";
            bl[i].onclick=openblind;
        }
    }
}
