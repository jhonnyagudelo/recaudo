

//fecha del dia
let meses = new Array ("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre");
	let diasSemana = new Array("Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado");
	let f=new Date();
	const day = document.getElementById('info__date');
	day.innerHTML =(diasSemana[f.getDay()] + ", " + f.getDate() + " de " + meses[f.getMonth()] + " de " + f.getFullYear());
	// day.innerHTML ='(diasSemana[f.getDay()] + ", " + f.getDate() + " de " + meses[f.getMonth()] + " de " + f.getFullYear());'

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




// modal

const $addButton = document.getElementById('add_tread');
const $cancelButton = document.getElementById('hiden-cancel');
const $modal = document.getElementById('modal');
const $form_modal = document.getElementById('form_modal');



$addButton.addEventListener('click', showModal);
function showModal(){
  $form_modal.classList.add('active');
  $modal.style.animation = 'animationIn 1s forwards'
};

$cancelButton.addEventListener('click', hideModal);
function hideModal(){
  $form_modal.classList.remove('active');
  $modal.style.animation = 'animationOut 3s forwards';
}


//modal_remove
const $deleteBus = document.querySelector('.delete__bus');
const $modalRemove = document.querySelector('.moda__vehicle-remov');
// const $modalRemove = document.querySelector('.moda__vehicle-remov');






//menu
const $movil = window.matchMedia('screen and (max-width: 480px)');
const $menu = document.querySelector('.header__nav-ul');
const $burgerButton = document.querySelector('#burger-button');

$movil.addListener (validation);
function validation (event) {
  if(event.matches) {
      $burgerButton.addEventListener('click', hideShow);
  }else {
    $burgerButton.addEventListener('click',hideShow);
  }
};
validation($movil);

    function hideShow() {
      if($menu.classList.contains('is-active')) {
  console.log(event)
        $menu.classList.remove('is-active');

      }else{
        $menu.classList.add('is-active');
      }
    }


