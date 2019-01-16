let interval     = [];
let nodemVersion = 'loading version...';

function initSystem () {
    let inputs   = [];
    let elements = document.getElementsByClassName('terminal-effect');

    for (let i = elements.length - 1; i >= 0; i--) {
        let id = Math.floor((Math.random() * 90000) + 1);
        interval.push(id);

        setTimeout(() => {
          this.write(elements[i].getAttribute('data'), elements[i], false, id);
        }, 1000);
    }
    this.getLastVersion();
}

function getLastVersion() {
  xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = () => {
      if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
          let dummy_html        = document.createElement('html');
          let el_version        = document.getElementById('version');
          dummy_html.innerHTML  = JSON.parse(xmlhttp.responseText).contents;
          nodemVersion          = dummy_html.getElementsByClassName('commit-title')[0].children[0].innerHTML;
          el_version.innerHTML  = nodemVersion;
      }
  }

  xmlhttp.open("GET", 'http://api.allorigins.ml/get?url=' + 'github.com/marcoT89/nodem/tags', true);
  xmlhttp.withCredentials = false;
  xmlhttp.setRequestHeader('Content-Type', 'application/json');
  xmlhttp.setRequestHeader('Accept',       'application/json');
  xmlhttp.send();
}

function write(text, el, clear, id = null) {
    clearInterval(interval[id]);
    el.innerHTML = '';

    interval[id] = setInterval(() => {
        el.innerHTML += text.substr(0, 1)
            .replace(' ', '&nbsp;')
            .replace('\n', "<br />")
            .replace('\1', '<a href="https://github.com/victoreduardobarreto" target="blank">barreto</a>')
            .replace('\2', '<a href="https://github.com/marcoT89" target="blank">marco tulio avila</a>')
            .replace('\3', '<a onClick="clipboard()" class="text-neon-hover">click to copy command on clipboard</a>')
        text = text.substr(1);
        if(!text.length) clearInterval(interval[id]);
    }, 20);
}

function terminal(param) {
    let text = '';

    switch(param) {
        case 'use':
            text = 'The available commands are: \n \n'
                  +'*install <version> \n'
                  +'nodem install 10.14.2 \n\n'
                  +'*use <version> \n'
                  +'nodem use 10.14.2 \n\n'
                  +'or with --npm to also use npm version for this node version \n'
                  +'nodem use 10.14.2 --npm \n\n'
                  +'*remove <version> \n'
                  +'nodem remove 10.14.2 \n\n'
                  +'*available \n'
                  +'nodem available \n\n'
                  +'*list \n'
                  +'nodem list \n\n'
                  +'*help \n'
                  +'nodem help \n\n';
        break;

        case 'install':
            text = '***warning*** \n'
                  +'wget is required! \n\n'
                  +'to install nodem just run this command on terminal: \n \n'
                  +'wget -O - https://raw.githubusercontent.com/marcoT89/nodem/master/install.sh | bash \n\n'
                  +'\3';
        break;

        case 'about':
            text = `nodem version : ${nodemVersion.trim()} \n`
                  +'license : MIT \n'
                  +'developer : \2 \n'
                  +'website design concept : \1 \n';
        break;
    }
    this.write(text, document.getElementById('terminal'), true);
}

function clipboard() {
    let el   = document.createElement('textarea');
    el.value = 'wget -O - https://raw.githubusercontent.com/marcoT89/nodem/master/install.sh | bash';
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
    this.write('copied.', document.getElementById('statusbar'), true);
    setTimeout(function() {
        document.getElementById('statusbar').innerHTML = '';
    }, 2000);
}
