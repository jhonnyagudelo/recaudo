$.ajax({
  url: "http://logirastreo.com/ws_app/resumenViaje.php?pass=b3dcd41072ccdbb7b7925f144f4dbaa7&inicio=2019-04-10 06:00:00&fin=2019-04-10 13:00:00",
  context: document.body
}).done(function(e) {
	if(e.viajes) {
		var ulO = document.getElementById("listaID");
		if(ulO) {
			document.body.removeChild(ulO);
		}

		var ul = document.createElement("ul");
		ul.id = "listaID";

		e.viajes.forEach(function(_item) {
			var li = document.createElement("li");
			var span = document.createElement("span");
			span.innerHTML = "Placa: " + _item.placa + " | viaje: " + _item.id_viaje;

			li.appendChild(span);
			ul.appendChild(li);
		});

		document.body.appendChild(ul);
	}
});



