

//fecha del dia
let meses = new Array ("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");
	let diasSemana = new Array("Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado");
	let f=new Date();
	document.getElementById('info__date').innerHTML =(diasSemana[f.getDay()] + ", " + f.getDate() + " de " + meses[f.getMonth()] + " de " + f.getFullYear());

//hora
function printTime (){
let d = new Date();
let hours = d.getHours();
let mins = d.getMinutes();
let secs = d.getSeconds();
document.getElementById('info__time').innerHTML = hours + ":" + mins + ":"+ secs;
}
setInterval(printTime);

let nav = document.getElementsByClassName("nav_link");
let i;

for (i = 0; i < nav.length; i++) {
  nav[i].addEventListener("click", function() {
    this.classList.toggle("active");
    let panel = this.nextElementSibling;
    if (panel.style.maxHeight){
      panel.style.maxHeight = null;
    } else {
      panel.style.maxHeight = panel.scrollHeight + "px";
    }
  });
}