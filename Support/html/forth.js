var menuCurrent = null;

function openMenu() {
	if (menuCurrent != null) {
		menuCurrent.style.display = 'none';
	}

	var menu = 'menu-' + this.id.substr(11);
	menu = document.getElementById(menu);
	menuCurrent = menu == menuCurrent ? null : menu;
}

function setCurrent(node) {
	var att = document.createAttribute('class');
	att.value = 'current';
	node.attributes.setNamedItem(att);
}

function removeCurrent(node) {
	var atts;
	var div;
	var n;
	do {
		div = node.firstElementChild;
		atts = div.attributes;
		for (n = 0; n < atts.length; n++) {
			if (atts[n].name == 'class') {
				atts[n].value = '';
				div.attributes = atts;
			}
		}
		node = node.nextElementSibling;
	} while (node);
}

function selectSecItem() {
	var div = this;
	div = div.parentElement;
	div = div.parentElement;
	removeCurrent(div.firstElementChild);
	div = div.parentElement;
	div = div.parentElement;
	div = div.firstElementChild;
	div.innerHTML = this.innerHTML;
	setCurrent(this);
	adjustScroll = true;
}

window.onclick = function () {
	if (menuCurrent != null) {
		var d = menuCurrent.style.display;
		if (d == '' || d == 'none') {
			menuCurrent.style.display = 'block';
		} else {
			menuCurrent.style.display = 'none';
			menuCurrent = null;
		}
	}
};

function menuBarSize() {
	var w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
	if (w < 767) {
		w = 0;
		var div = document.getElementById('menu-bar');
		div = div.firstElementChild;
		div = div.firstElementChild;
		while (div) {
			w++;
			div = div.nextElementSibling;
		}
	} else {
		w = 1;
	}
	return w * 25;
}

var adjustScroll = true;
window.onscroll = function () {
	if (adjustScroll) {
		setTimeout(function () {
			window.scrollBy(0, -menuBarSize());
		}, 200);
		adjustScroll = false;
	}
}

window.onload = function () {
	var list = ["doc", "chap", "sec", "word"];
	for (var n in list) {
		var name = "menu-label-" + list[n];
		var div = document.getElementById(name);
		if (div != null) {
			div.onclick = openMenu;
			if (n == 2) {
				div = div.nextElementSibling;
				div = div.firstElementChild;
				div = div.firstElementChild;
				do {
					div.firstElementChild.onclick = selectSecItem;
					div = div.nextElementSibling;
				} while (div);
			}
		}
	}

	var div = document.getElementById('body');
	div.style.marginTop = menuBarSize() + 'px';
}

function email() {
	var a = Array();
	for (var n in arguments) {
		a.unshift(arguments[n]);
	}
	document.write(a.shift(), '&#64;', a.join('&#46;'));
}
