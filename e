class Store {
    constructor(config) {
        this.config = JSON.parse(config);
    }

    get = (key) => this.config[key];
    set = (key, value) => {
        this.config[key] = value;
        localStorage.saveSettings = JSON.stringify(this.config);
    }
}

if (!localStorage.saveSettings) localStorage.saveSettings = JSON.stringify({
    permCrosshair: true,
    customCss: false,
    hideWeaponsAds: false,
    hideArms: false,
    leftHanded: false,
    hideFlagAds: false,
    playerHighLight: false,
    weaponHighlighter: false,
    rgbHighlight: false,
    wireframeWeapons: false,
    wireframeArms: false,
    rainbow: false,
    adspower: false,
    autoJoin: false,
    inspectKey: "j",
    menuKey: "click to bind",
    euLobbies: true,
    naLobbies: false,
    asiaLobbies: false,
    ffaLobbies: true,
    tdmLobbies: true,
    parkourLobbies: false,
    preferredFilter: 'Players',
    minPlayers: 4,
    maxPlayers: 8,
    minTimeLeft: 3,
    filterMaps: false,
    maps: '',
    customGames: false,
    cssLink: '',
    skinlink: ",
    menuOpen: true,
    volume: 1,
    noKillSound: false,
    marketNames: false,
    customHitmarker: false,
    customHitmarkerSrc: ''
});

const settings = new Store(localStorage.saveSettings);

let permCrosshair = !!settings.get('permCrosshair');
let noLoadingTimes = true;
let customCss = !!settings.get('customCss');
let customSkinLink = !!settings.get('customSkinLink);
//let hpNumber = true;
let hideWeaponsAds = !!settings.get('hideWeaponsAds');
let hideArms = !!settings.get('hideArms');
let leftHanded = !!settings.get('leftHanded');
let hideFlagAds = !!settings.get('hideFlagAds');
let playerHighLight = !!settings.get('playerHighLight');
let weaponHighlighter = !!settings.get('weaponHighlighter');
let rgbHighlight = !!settings.get('rgbHighlight');
let wireframeWeapons = !!settings.get('wireframeWeapons');
let wireframeArms = !!settings.get('wireframeArms');
let rainbow = !!settings.get('rainbow');
let adspower = !!settings.get('adspower');
let autoJoin = !!settings.get('autoJoin');
let volume = typeof settings.get('volume') == 'undefined' ? 1 : settings.get('volume');
let noKillSound = !!settings.get('noKillSound');

let volumeSlider;
let volumeLab;

let marketNames = !!settings.get('marketNames');

let inspecting = false;
let prevInsp = false;
let prevInspectPos;
let prevInspectRot;
let prevWireframeWeapons = false;
let prevWireframeArms = false;

let gui = document.createElement("div");
let menuVisible = false;

let inspectListening = false;
if (!settings.get('inspectKey')) settings.set('inspectKey', "j");

let menuListening = false;

let euLobbies = !!settings.get('euLobbies');
let naLobbies = !!settings.get('naLobbies');
let asiaLobbies = !!settings.get('asiaLobbies');
let ffaLobbies = !!settings.get('ffaLobbies');
let tdmLobbies = !!settings.get('tdmLobbies');
let parkourLobbies = !!settings.get('parkourLobbies');
let preferredFilter = typeof settings.get('preferredFilter') == 'undefined' ? 'Players' : settings.get('preferredFilter');
let minPlayers = typeof settings.get('minPlayers') == 'undefined' ? 4 : settings.get('minPlayers');
let maxPlayers = typeof settings.get('maxPlayers') == 'undefined' ? 8 : settings.get('maxPlayers');
let minTimeLeft = typeof settings.get('minTimeLeft') == 'undefined' ? 3 : settings.get('minTimeLeft');
let filterMaps = !!settings.get('filterMaps');
let avoidSameLobby = true;
let currentURL = window.location.href;
let gameModes = [];
let bestLobby = '';
let allLobbyData = [];
let maps = settings.get('maps') ? settings.get('maps') : [];
let customGames = !!settings.get('customGames');
let responseCount = 0;
let minPlayerSlider;
let maxPlayerSlider;
let minPlayersLab;
let maxPlayersLab;
let minTimeLeftSlider;
let minTimeLeftLab;
let settingsButtonsAdded = false;
let customHitmarker = !!settings.get('customHitmarker');
let customHitmarkerSrc = !!settings.get('customHitmarkerSrc');

let scene;
let flagMaterial;
let players;
let gains = [];
let overlayModel;

WeakMap.prototype.set = new Proxy(WeakMap.prototype.set, {
    apply(target, thisArg, argArray) {

        if (argArray[0] && argArray[0].type === 'Scene') {
            if (argArray[0].children[0].type === 'AmbientLight') {
                scene = argArray[0];

                setTimeout(() => {
                    scene.children.forEach((e) => {
                        if (e.type === "Sprite" && !e.material.depthTest && e.material.map?.image?.width === 149) {
                            flagMaterial = e.material;
                        }
                    })
                }, 1000);

            } else if (argArray[0]?.children[0]?.children[0]?.type === "PerspectiveCamera") {
                overlayModel = argArray[0].children[0].children[0].children[0];
            }
        }

        return Reflect.apply(...arguments);
    }
});

let crosshair;

new MutationObserver(mutationRecords => {
    try {
        mutationRecords.forEach(record => {
            record.addedNodes.forEach(el => {
                if (el.classList?.contains("loading-scene") && noLoadingTimes) el.parentNode.removeChild(el);
                if (el.id === "qc-cmp2-container") el.parentNode.removeChild(el);
                if (el.id === "cmpPersistentLink" || el.classList?.contains("home") || el.classList?.contains('moneys')) {

                    let btn = document.createElement("button");

                    btn.id = "clientJoinButton";

                    btn.style = "background-color: var(--primary-1);\n" +
                        "    --hover-color: var(--primary-2);\n" +
                        "    --top: var(--primary-2);\n" +
                        "    --bottom: var(--primary-3);" +
                        "    display: flex ;\n" +
                        "    justify-content: center;\n" +
                        "    align-items: center;\n" +
                        "    border: none;\n" +
                        "    position: absolute;\n" +
                        "    color: var(--white);\n" +
                        "    font-size: 1rem;\n" +
                        "    transition: all .3s ease;\n" +
                        "    font-family: Rowdies;\n" +
                        "    padding: .9em 1.4em;\n" +
                        "    transform: skew(-10deg);\n" +
                        "    font-weight: 900;\n" +
                        "    overflow: hidden;\n" +
                        "    text-transform: uppercase;\n" +
                        "    border-radius: .2em;\n" +
                        "    outline: none;\n" +
                        "    text-shadow: 0 0.1em 0 #000;\n" +
                        "    -webkit-text-stroke: 1px var(--black);\n" +
                        "    box-shadow: 0 0.15rem 0 rgba(0,0,0,.315);\n" +
                        "    cursor: pointer;" +
                        "    box-shadow: 0 5.47651px 0 rgba(0,0,0,.5)!important;\n" +
                        "    text-shadow: -1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000,0 1px 1px rgba(0,0,0,.486)!important;" +
                        "    width: 150px;" +
                        "    height: 50px;" +
                        "    bottom: 20px;" +
                        "    right: 100%;" +
                        "    margin-right: 10px;" +
                        "    font-size: 20px;";


                    btn.innerText = "Join Link";

                    btn.onclick = async () => {
                        window.location.href = await navigator.clipboard.readText();
                    }

                    if (document.getElementsByClassName("nickname")[0]) {
                        const i = setInterval(() => {
                            let id = document.getElementsByClassName('username')[0]?.innerText;
                            if (id && !document.getElementById("menuBadge") && badgeLinks[id]) {
                                const badgeElement = document.createElement("div");
                                badgeElement.innerHTML = `<img data-v-c5d917c8="" src="${badgeLinks[id]}" id="menuBadge">`;
                                document.getElementsByClassName("nickname")[0].appendChild(badgeElement);
                                clearInterval(i);
                            }
                        }, 100);
                    }

                    if (!document.getElementById("clientJoinButton")) document.getElementsByClassName('play-content')[0].append(btn);

                    document.getElementsByClassName('settings-and-socicons')[0].children[0].onclick = () => {
                        window.location.href = "https://discord.com/invite/cNwzjsFHpg";
                    };

                    document.getElementsByClassName('settings-and-socicons')[0].children[1].onclick = () => {
                        window.location.href = "https://github.com/42infi/better-kirka-client/releases";
                    };

                    if (!el.classList?.contains("home") && !el.classList?.contains('moneys')) el.parentNode.removeChild(el);

                }
                if (el.classList?.contains("game-interface")) {
                    crosshair = document.getElementById("crosshair-static");

                    const statsWrapper = document.getElementsByClassName("kill-death")[0];
                    const killElement = document.getElementsByClassName("kill bg text-1")[0];
                    const deathElement = document.getElementsByClassName("death bg text-1")[0];

                    const kdrElem = document.createElement("div");
                    kdrElem.innerHTML += `<div data-${Object.keys(deathElement.dataset)[0]}="" class="kill bg text-1" id="kdrElem">K/D: 0</div>`;

                    statsWrapper.appendChild(kdrElem);

                    const kdrText = document.getElementById("kdrElem");

                    function onStatsUpdate() {
                        kdrText.innerText = `K/D: ${Math.round((Number.parseInt(killElement.innerText) / Math.max(Number.parseInt(deathElement.innerText), 1)) * 100) / 100}`;
                    }

                    killElement.addEventListener("DOMCharacterDataModified", onStatsUpdate);
                    deathElement.addEventListener("DOMCharacterDataModified", onStatsUpdate);
                }

                if (el.classList?.contains("settings") && !settingsButtonsAdded) {

                    let exportBtn = document.createElement('div');

                    exportBtn.id = "importBtn";

                    exportBtn.style = "line-height: 1.2;\n" +
                        "user-select: none;\n" +
                        "--white: #fff;\n" +
                        "--secondary-2: #37477c;\n" +
                        "-webkit-font-smoothing: antialiased;\n" +
                        "text-align: center;\n" +
                        "font-family: Exo\\ 2;\n" +
                        "box-sizing: border-box;\n" +
                        "text-shadow: -1px -1px 0 #0f0f0f,1px -1px 0 #0f0f0f,-1px 1px 0 #0f0f0f,1px 1px 0 #0f0f0f;\n" +
                        "font-weight: 100;\n" +
                        "height: 100%;\n" +
                        "padding: 0 .8rem;\n" +
                        "color: var(--white);\n" +
                        "font-size: 1.5rem;\n" +
                        "box-shadow: 0 .125rem .25rem rgba(24,28,40,.25);\n" +
                        "border-radius: 0 .313rem .313rem 0;\n" +
                        "background-color: var(--secondary-2);\n" +
                        "display: flex;\n" +
                        "justify-content: center;\n" +
                        "align-items: center;"

                    exportBtn.onmouseover = () => {
                        exportBtn.style.color = "#ffd500";
                    }

                    exportBtn.onmouseout = () => {
                        exportBtn.style.color = "#ffffff";
                    }

                    exportBtn.innerText = "Export to clipboard"

                    exportBtn.onclick = async () => {
                        let gameSettingsObj = {};

                        for (let key in localStorage) {
                            if (key.startsWith("m")) {
                                if (localStorage[key].startsWith('"') && localStorage[key].endsWith('"')) {
                                    gameSettingsObj[key] = localStorage[key].slice(1, -1);
                                } else {
                                    gameSettingsObj[key] = localStorage[key];
                                }
                            }
                        }

                        try {
                            navigator.clipboard.writeText(JSON.stringify(gameSettingsObj));
                        } catch {
                            throw new Error("Copying to clipboard failed")
                        }
                        //clipboard.writeText(JSON.stringify(gameSettingsObj));
                    }


                    let importBtn = document.createElement('div');

                    importBtn.id = "importBtn";

                    importBtn.style = "line-height: 1.2;\n" +
                        "user-select: none;\n" +
                        "--white: #fff;\n" +
                        "--secondary-2: #37477c;\n" +
                        "-webkit-font-smoothing: antialiased;\n" +
                        "text-align: center;\n" +
                        "font-family: Exo\\ 2;\n" +
                        "box-sizing: border-box;\n" +
                        "text-shadow: -1px -1px 0 #0f0f0f,1px -1px 0 #0f0f0f,-1px 1px 0 #0f0f0f,1px 1px 0 #0f0f0f;\n" +
                        "font-weight: 100;\n" +
                        "height: 100%;\n" +
                        "padding: 0 .8rem;\n" +
                        "color: var(--white);\n" +
                        "font-size: 1.5rem;\n" +
                        "box-shadow: 0 .125rem .25rem rgba(24,28,40,.25);\n" +
                        "border-radius: 0 .313rem .313rem 0;\n" +
                        "background-color: var(--secondary-2);\n" +
                        "display: flex;\n" +
                        "justify-content: center;\n" +
                        "align-items: center;"

                    importBtn.onmouseover = () => {
                        importBtn.style.color = "#ffd500";
                    }

                    importBtn.onmouseout = () => {
                        importBtn.style.color = "#ffffff";
                    }

                    importBtn.innerText = "Import from clipboard"

                    importBtn.onclick = () => {
                        //Object.assign(localStorage, JSON.parse(clipboard.readText()));
                        //window.location.reload();
                    }

                    document.getElementsByClassName('left')[0].appendChild(exportBtn);
                    document.getElementsByClassName('left')[0].appendChild(importBtn);

                    settingsButtonsAdded = true;

                }
            });
        });
    } catch {
    }
}).observe(document, { childList: true, subtree: true });

//old adblock
/*
let oldLog = console.log;

console.log = (...arguments) => {
    if (typeof arguments[0] == "string" && arguments[0].startsWith("window.aiptag.cmd")) {
        throw "ad's blocked by overengineered ad block " + Math.random().toString().split(".")[1];
    }
    oldLog(...arguments);
};
*/

//new adblock
Object.defineProperty(window, 'aiptag', {
    set(v) {
    },
    get() {
    }
});

if (customCss) {
    let cssLinkElem = document.createElement("link");
    cssLinkElem.href = settings.get('cssLink');
    cssLinkElem.rel = "stylesheet";
    document.head.append(cssLinkElem);
    
    if (customSkin) {
    let skinLinkElem = document.createElement("link");
    skinLinkElem.href = settings.get('skinLink');
    skinLinkElem.rel = "stylesheet";
    document.head.append(skinLinkElem);
}

gui.id = "gui";

gui.innerHTML += "<style>\n" +
    "        @import url('https://fonts.googleapis.com/css2?family=Titillium+Web:wght@300&display=swap');\n" +
    "\n" +
    "        #gui {\n" +
    "            background-color: rgb(24, 25, 28);\n" +
    "            border: solid rgb(24, 25, 28) 5px;\n" +
    "            box-shadow: 0 0 8px 2px #000000;\n" +
    "            position: absolute;\n" +
    "            left: 200px;\n" +
    "            top: 60px;\n" +
    "            z-index: 300;\n" +
    "            color: rgb(255, 255, 255);\n" +
    "            padding: 6px;\n" +
    "            font-family: \"Titillium Web\", serif;\n" +
    "            line-height: 1.6;\n" +
    "            border-radius: 3px;\n" +
    "            max-width: 390px;\n" +
    "        }\n" +
    "\n" +
    "        input:disabled {\n" +
    "            background: rgb(255, 255, 255);\n" +
    "            border: solid rgb(0, 0, 0) 1px;\n" +
    "            width: 50px;\n" +
    "        }\n" +
    "\n" +
    "        .heading {\n" +
    "            width: 380px;\n" +
    "            height: 40px;\n" +
    "            display: flex;\n" +
    "            justify-content: center;\n" +
    "            align-items: center;\n" +
    "            background-color: rgb(24, 25, 28);\n" +
    "            margin: -9px -6px 8px;\n" +
    "            font-family: \"Titillium Web\", serif;\n" +
    "            font-weight: bold;\n" +
    "            text-align: center;\n" +
    "            font-size: 24px;\n" +
    "            border-bottom: solid rgb(140, 140, 140) 2px;\n" +
    "        }\n" +
    "\n" +
    "        .footer {\n" +
    "            width: 380px;\n" +
    "            height: 20px;\n" +
    "            display: flex;\n" +
    "            justify-content: center;\n" +
    "            align-items: center;\n" +
    "            background-color: rgb(24, 25, 28);\n" +
    "            margin: 6px -6px -10px;\n" +
    "            font-family: \"Titillium Web\", serif;\n" +
    "            font-weight: bold;\n" +
    "            text-align: center;\n" +
    "            font-size: 11px;\n" +
    "            position: relative;\n" +
    "            border-top: solid rgb(140, 140, 140) 2px;\n" +
    "        }\n" +
    "\n" +
    "        .module:hover {\n" +
    "            background-color: rgb(0, 0, 0, 0.1)\n" +
    "        }\n" +
    "\n" +
    "        .autojoin{\n" +
    "            display: none;\n" +
    "        }\n" +
    "\n" +
    "    </style>\n" +
    "    <div id=\"infi\" class=\"heading\">Script Settings</div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"crosshair\" name=\"crosshair\">\n" +
    "        <label for=\"crosshair\">Perm. Crosshair</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"customCSS\" name=\"customCSS\">\n" +
    "        <label for=\"customCSS\">CSS Link: </label>\n" +
    "        <input type=\"text\" id=\"cssLink\" placeholder=\"Paste CSS Link Here\">\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"customskin\" name=\"customskin\">\n" +
    "        <label for=\"customskin\">skin Link: </label>\n" +
    "        <input type=\"text\" id=\"skinLink\" placeholder=\"Paste Skin Link Here\">\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"hideweap\" name=\"hideweap\">\n" +
    "        <label for=\"hideweap\">Hide Weapon ADS</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"arms\" name=\"arms\">\n" +
    "        <label for=\"arms\">Hide Arms</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"leftHanded\" name=\"leftHanded\">\n" +
    "        <label for=\"leftHanded\">Left Handed</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"hideflag\" name=\"hideflag\">\n" +
    "        <label for=\"hideflag\">Hide Flag ADS</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"highlight\" name=\"highlight\">\n" +
    "        <label for=\"highlight\">Highlight Players</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"weaponHighlighter\" name=\"weaponHighlighter\">\n" +
    "        <label for=\"weaponHighlighter\">Weapon Highlighting</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"rgbHighlight\" name=\"rgbHighlight\">\n" +
    "        <label for=\"rgbHighlight\">Rainbow Highlighting</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"wireframeWeapons\" name=\"wireframeWeapons\">\n" +
    "        <label for=\"wireframeWeapons\">Wireframe Weapons</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"wireframeArms\" name=\"wireframeArms\">\n" +
    "        <label for=\"wireframeArms\">Wireframe Arms</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"rainbow\" name=\"rainbow\">\n" +
    "        <label for=\"rainbow\">Rainbow Colors</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        Inspect Key\n" +
    "        <button id=\"inspBindButton\" style=\"width: 100px\">click to bind</button>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"adspower\" name=\"adspower\">\n" +
    "        <label for=\"adspower\">0 ADS Power</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"autoJoin\" name=\"autoJoin\">\n" +
    "        <label for=\"autoJoin\">Auto-Joiner (Key F8)</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <hr class=\"autojoin\">\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"checkbox\" id=\"euLobbies\" name=\"euLobbies\">\n" +
    "        <label for=\"euLobbies\">EU Lobbies</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"checkbox\" id=\"naLobbies\" name=\"naLobbies\">\n" +
    "        <label for=\"naLobbies\">NA Lobbies</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"checkbox\" id=\"asiaLobbies\" name=\"asiaLobbies\">\n" +
    "        <label for=\"asiaLobbies\">ASIA Lobbies</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"checkbox\" id=\"ffaLobbies\" name=\"ffaLobbies\">\n" +
    "        <label for=\"ffaLobbies\">FFA Lobbies</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"checkbox\" id=\"tdmLobbies\" name=\"tdmLobbies\">\n" +
    "        <label for=\"tdmLobbies\">TDM Lobbies</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"checkbox\" id=\"parkourLobbies\" name=\"parkourLobbies\">\n" +
    "        <label for=\"parkourLobbies\">PARKOUR Lobbies</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <label for=\"preferredFilter\">Prefered Filter:</label>\n" +
    "        <select id=\"preferredFilter\" name=\"preferredFilter\">\n" +
    "            <option value=\"Time\">Time</option>\n" +
    "            <option value=\"Players\">Players</option>\n" +
    "        </select>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"range\" id=\"minPlayers\" name=\"minPlayers\" min=\"0\" max=\"8\" value=\"0\" step=\"1\">\n" +
    "        <label id=\"minPlayersLab\" for=\"minPlayers\">min. Players</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"range\" id=\"maxPlayers\" name=\"maxPlayers\" min=\"0\" max=\"8\" value=\"0\" step=\"1\">\n" +
    "        <label id=\"maxPlayersLab\" for=\"maxPlayers\">max. Players</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"range\" id=\"minTimeLeft\" name=\"minTimeLeft\" min=\"0\" max=\"8\" value=\"0\" step=\"1\">\n" +
    "        <label id=\"minTimeLeftLab\" for=\"minTimeLeft\">min. Time Left</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"checkbox\" id=\"filterMaps\" name=\"filterMaps\">\n" +
    "        <label for=\"filterMaps\">Map Filter: </label>\n" +
    "        <input type=\"text\" id=\"mapFilterField\" placeholder=\"Map1, Map2, Map3, etc.\">\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module autojoin\">\n" +
    "        <input type=\"checkbox\" id=\"customGames\" name=\"customGames\">\n" +
    "        <label for=\"customGames\">Custom Games </label>\n" +
    "    </div>\n" +
    "\n" +
    "    <hr class=\"autojoin\">\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        Menu Toggle Key\n" +
    "        <button id=\"menuBindButton\" style=\"width: 100px\">click to bind</button>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"range\" id=\"volume\" name=\"volume\" min=\"0\" max=\"2\" value=\"1\" step=\"0.1\">\n" +
    "        <label id=\"volumeLab\" for=\"volume\">Volume</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"noKillSound\" name=\"noKillSound\">\n" +
    "        <label for=\"noKillSound\">Disable Killsounds (applies after reload)</label>\n" +
    "    </div>\n" +
    "\n" +
    "    <div class=\"module\">\n" +
    "        <input type=\"checkbox\" id=\"customHitmarker\" name=\"customHitmarker\">\n" +
    "        <label for=\"customHitmarkerLink\">Hitmarker Link: </label>\n" +
    "        <input type=\"text\" id=\"customHitmarkerLink\" placeholder=\"Paste Hitmarker Link\">\n" +
    "    </div>\n" +
    "\n" +
    " <div class=\"footer\">Toggle With \"PageUp\" or \"F8\" Key</div>";


gui.onclick = (e) => {

    if (e.target.id === "crosshair") {
        permCrosshair = e.target.checked;
        settings.set('permCrosshair', permCrosshair);
    }

    if (e.target.id === "customCSS") {
        customCss = e.target.checked;
        settings.set('customCss', customCss);
     }
            if (e.target.id === "customskin") {
        customSkin = e.target.checked;
        settings.set('customSkin', customSkin);
    }

    if (e.target.id === "hideweap") {
        hideWeaponsAds = e.target.checked;
        settings.set('hideWeaponsAds', hideWeaponsAds);
    }

    if (e.target.id === "arms") {
        hideArms = e.target.checked;
        settings.set('hideArms', hideArms);
    }

    if (e.target.id === "leftHanded") {
        leftHanded = e.target.checked;
        settings.set('leftHanded', leftHanded);
    }


    if (e.target.id === "hideflag") {
        hideFlagAds = e.target.checked;
        settings.set('hideFlagAds', hideFlagAds);
    }


    if (e.target.id === "highlight") {
        playerHighLight = e.target.checked;
        settings.set('playerHighLight', playerHighLight);
    }

    if (e.target.id === "weaponHighlighter") {
        weaponHighlighter = e.target.checked;
        settings.set('weaponHighlighter', weaponHighlighter);
    }

    if (e.target.id === "rgbHighlight") {
        rgbHighlight = e.target.checked;
        settings.set('rgbHighlight', rgbHighlight);
    }

    if (e.target.id === "wireframeWeapons") {
        wireframeWeapons = e.target.checked;
        settings.set('wireframeWeapons', wireframeWeapons);
    }

    if (e.target.id === "wireframeArms") {
        wireframeArms = e.target.checked;
        settings.set('wireframeArms', wireframeArms);
    }

    if (e.target.id === "rainbow") {
        rainbow = e.target.checked;
        settings.set('rainbow', rainbow);
    }

    if (e.target.id === "adspower") {
        adspower = e.target.checked;
        settings.set('adspower', adspower);
    }

    if (e.target.id === "autoJoin") {
        autoJoin = e.target.checked;
        settings.set('autoJoin', autoJoin);
        for (let e of document.getElementsByClassName('autojoin')) {
            e.style.display = autoJoin ? 'block' : 'none'
        }
    }

    if (e.target.id === "euLobbies") {
        euLobbies = e.target.checked;
        settings.set('euLobbies', euLobbies);
    }

    if (e.target.id === "naLobbies") {
        naLobbies = e.target.checked;
        settings.set('naLobbies', naLobbies);
    }

    if (e.target.id === "asiaLobbies") {
        asiaLobbies = e.target.checked;
        settings.set('asiaLobbies', asiaLobbies);
    }

    if (e.target.id === "ffaLobbies") {
        ffaLobbies = e.target.checked;
        settings.set('ffaLobbies', ffaLobbies);
    }

    if (e.target.id === "tdmLobbies") {
        tdmLobbies = e.target.checked;
        settings.set('tdmLobbies', tdmLobbies);
    }

    if (e.target.id === "parkourLobbies") {
        parkourLobbies = e.target.checked;
        settings.set('parkourLobbies', parkourLobbies);
    }

    if (e.target.id === "filterMaps") {
        filterMaps = e.target.checked;
        settings.set('filterMaps', filterMaps);
    }

    if (e.target.id === "customGames") {
        customGames = e.target.checked;
        settings.set('customGames', customGames);
    }

    if (e.target.id === "noKillSound") {
        noKillSound = e.target.checked;
        settings.set('noKillSound', noKillSound);
    }

    if (e.target.id === "marketNames") {
        marketNames = e.target.checked;
        settings.set('marketNames', marketNames);
    }

    if (e.target.id === "customHitmarker") {
        customHitmarker = e.target.checked;
        settings.set('customHitmarker', customHitmarker);
    }

};

gui.style.display = "none";

document.body.appendChild(gui);

if (settings.get('menuOpen') === undefined || settings.get('menuOpen')) {
    toggleGui();
}

document.getElementById("crosshair").checked = permCrosshair;

document.getElementById("customCSS").checked = customCss;

const cssField = document.getElementById('cssLink');

if (settings.get('cssLink') === undefined) settings.set('cssLink', '');

cssField.value = settings.get('cssLink');

cssField.oninput = () => {
    settings.set('cssLink', cssField.value);
    
document.getElementById("customskin").checked = customSkin;

const skinField = document.getElementById('skinLink');

if (settings.get('skinLink') === undefined) settings.set('skinLink', '');

skinField.value = settings.get('skinLink');

skinField.oninput = () => {
    settings.set('skinLink', skinField.value);
}

document.getElementById("hideweap").checked = hideWeaponsAds;
document.getElementById("arms").checked = hideArms;
document.getElementById("leftHanded").checked = leftHanded;
document.getElementById("hideflag").checked = hideFlagAds;
document.getElementById("highlight").checked = playerHighLight;
document.getElementById("weaponHighlighter").checked = weaponHighlighter;
document.getElementById("rgbHighlight").checked = rgbHighlight;
document.getElementById("wireframeWeapons").checked = wireframeWeapons;
document.getElementById("wireframeArms").checked = wireframeArms;
document.getElementById("rainbow").checked = rainbow;
document.getElementById("adspower").checked = adspower;

maxPlayersLab = document.getElementById('maxPlayersLab');
minPlayersLab = document.getElementById('minPlayersLab');
minTimeLeftLab = document.getElementById('minTimeLeftLab');

maxPlayerSlider = document.getElementById("maxPlayers");
minPlayerSlider = document.getElementById("minPlayers");
minTimeLeftSlider = document.getElementById("minTimeLeft");

maxPlayerSlider.onchange = () => {
    settings.set('maxPlayers', Number.parseInt(maxPlayerSlider.value));
}

minPlayerSlider.onchange = () => {
    settings.set('minPlayers', Number.parseInt(minPlayerSlider.value));
}

minTimeLeftSlider.onchange = () => {
    settings.set('minTimeLeft', Number.parseInt(minTimeLeftSlider.value));
}

minPlayerSlider.value = minPlayers;
maxPlayerSlider.value = maxPlayers;
minTimeLeftSlider.value = minTimeLeft;

if (autoJoin) {
    for (let e of document.getElementsByClassName('autojoin')) {
        e.style.display = autoJoin ? 'block' : 'none'
    }
}

document.getElementById("autoJoin").checked = autoJoin;
document.getElementById("euLobbies").checked = euLobbies;
document.getElementById("naLobbies").checked = naLobbies;
document.getElementById("asiaLobbies").checked = asiaLobbies;
document.getElementById("ffaLobbies").checked = ffaLobbies;
document.getElementById("tdmLobbies").checked = tdmLobbies;
document.getElementById("parkourLobbies").checked = parkourLobbies;

let inspectBindButton = document.getElementById("inspBindButton");
inspectBindButton.style.fontWeight = "800";
inspectBindButton.onclick = () => {
    inspectListening = true;
    inspectBindButton.innerText = "Press a Key"
}

inspectBindButton.innerText = settings.get('inspectKey').toUpperCase();

let filter = document.getElementById("preferredFilter");

filter.value = preferredFilter;

filter.onchange = () => {
    preferredFilter = filter.value;
    settings.set('preferredFilter', filter.value);
}

document.getElementById("filterMaps").checked = filterMaps;

let mapField = document.getElementById("mapFilterField");

let mapString = "";
for (let name of maps) {
    mapString += name + ", "
}

mapField.value = mapString.slice(0, -2);

mapField.oninput = () => {
    maps = mapField.value.replace(/ /g, '').toLowerCase().split(',');
    settings.set('maps', maps);
}

document.getElementById("customGames").checked = customGames;

let menuBindButton = document.getElementById("menuBindButton");
menuBindButton.style.fontWeight = "800";
menuBindButton.onclick = () => {
    menuListening = true;
    menuBindButton.innerText = "Press a Key"
}

menuBindButton.innerText = settings.get("menuKey") !== undefined ? settings.get("menuKey").toUpperCase() : "click to bind";


document.getElementById("noKillSound").checked = noKillSound;


volumeLab = document.getElementById('volumeLab');
volumeSlider = document.getElementById("volume");

volumeSlider.onchange = () => {
    settings.set('volume', Number.parseFloat(volumeSlider.value));
    for (let i = 0; i < gains.length; i++) {
        const cur = gains[i];
        if (cur) cur.value = volume;
    }
}

volumeSlider.value = volume;

let customHitmarkerField = document.getElementById('customHitmarkerLink');

if (settings.get('customHitmarkerLink') === undefined) settings.set('customHitmarkerLink', '');

customHitmarkerField.value = settings.get('customHitmarkerLink');

customHitmarkerField.oninput = () => {
    settings.set('customHitmarkerLink', customHitmarkerField.value);
}

document.getElementById("customHitmarker").checked = customHitmarker;


const ingameIds = [
    '#MTK3Z5', '#4DD3XZ', '#2Q0QKL', '#YYRHG7', '#W5J3AB', '#6FIJZY', '#HVCL3P', '#7PWLQI', '#FAYQ0E', '#QCZSZK', '#6L1WRO', '#Z37B0Z', '#6IUE15', '#UVPIAP', '#4HCBF4', '#QH8CEO', '#UH98AE', '#C8KLSB', '#Y64AN1'
];

const badgeLinks = {
    default: 'https://cdn.discordapp.com/attachments/738010330780926004/1017163938993020939/Untitled-finalihope.png',
    '#MTK3Z5': 'https://cdn.discordapp.com/attachments/1010612280775422093/1019727079320854528/rsz_2667.png',
    '#4DD3XZ': 'https://cdn.discordapp.com/attachments/738010330780926004/1027331355656331376/unknown.png',
    '#2Q0QKL': 'https://cdn.discordapp.com/attachments/738010330780926004/1020042667276632084/devbadge.png',
    '#YYRHG7': 'https://cdn.discordapp.com/attachments/738010330780926004/1020042667276632084/devbadge.png',
    '#W5J3AB': '',
    '#6FIJZY': '',
    '#HVCL3P': '',
    '#7PWLQI': '',
    '#FAYQ0E': '',
    '#QCZSZK': '',
    '#6L1WRO': '',
    '#Z37B0Z': 'https://cdn.discordapp.com/attachments/738010330780926004/1040977499384979517/b57d2718c0f2330c0e06166d4b5fb606.png',
    '#6IUE15': 'https://cdn.discordapp.com/attachments/738010330780926004/1040977499384979517/b57d2718c0f2330c0e06166d4b5fb606.png',
    '#UVPIAP': '',
    '#4HCBF4': 'https://cdn.discordapp.com/attachments/738010330780926004/1040977499384979517/b57d2718c0f2330c0e06166d4b5fb606.png',
    '#QH8CEO': '',
    '#UH98AE': '',
    '#C8KLSB': '',
    '#Y64AN1': '',
    '#D84BWU': 'https://cdn.discordapp.com/attachments/738010330780926004/1046046359884677170/greentick.png',
    '#T5KBH4': '',
    '#NV6BPK': '',
    '#LORZQI': '',
    '#JPI0TQ': '',
    '#P4B05K': '',
    '#6YGZWX': 'https://cdn.discordapp.com/attachments/738010330780926004/1048757530706333757/lelBadge.png',
    '#DU8C8P': ''
};

let imgTags = [];
let hasPlayerList = false;


function appendBadges() {
    players.querySelectorAll('.short-id').forEach((e) => {

        if (ingameIds.includes(e.innerText)) {
            let img = document.createElement("img");

            img.src = badgeLinks[e.innerText] !== '' ? badgeLinks[e.innerText] : badgeLinks.default;

            imgTags.push(img);

            e.parentElement.children[1].append(img);
        }

    });
}

setInterval(() => {


    players = document.getElementsByClassName('players')?.[0];

    if (!players) gains = [];

    if (!hasPlayerList && players) {

        appendBadges();

        const observer = new MutationObserver((mutation) => {

            let n = false;

            mutation.forEach((e) => {
                e.addedNodes.forEach((f) => {
                    if (f.nodeName === "IMG") n = true;
                });
            });

            if (n) return;

            for (let imgTag of imgTags) {
                if (imgTag) imgTag.parentElement.removeChild(imgTag);
            }

            imgTags = [];

            appendBadges();

        });
        observer.observe(players, {
            attributes: true,
            characterData: true,
            childList: true,
            subtree: true,
            attributeOldValue: true,
            characterDataOldValue: true
        });
    }

    hasPlayerList = !!players;
}, 1000);


//credit to Sheriff for the cw time display

let isClanWarPage = false
let updating = false

async function clanWarUsers() {

    let clanLb = await fetch("https://api.kirka.io/api/leaderboard/clanChampionship", {
        "headers": {
            "accept": "application/json, text/plain, */*",
            "sec-fetch-site": "same-site"
        },
        "referrer": "https://kirka.io/hub/clans/champions-league",
        "referrerPolicy": "no-referrer-when-downgrade",
        "body": null,
        "method": "GET",
    })

    let clanLbJson = await clanLb.json()

    document.getElementsByClassName("reset-time")[0].innerHTML = '<svg data-v-49b1054a="" data-v-0684cd73="" xmlns="http://www.w3.org/2000/svg" class="time svg-icon svg-icon--clock"><!----><use data-v-49b1054a="" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/img/icons.6e41b8dd.svg#clock"></use></svg> Reset in ' + Math.floor(clanLbJson.remainingTime / 86400000) + "d " + Math.floor((clanLbJson.remainingTime / 86400000 - Math.floor(clanLbJson.remainingTime / 86400000)) * 24) + "h " + Math.floor(((clanLbJson.remainingTime / 86400000 - Math.floor(clanLbJson.remainingTime / 86400000)) * 24 - Math.floor((clanLbJson.remainingTime / 86400000 - Math.floor(clanLbJson.remainingTime / 86400000)) * 24)) * 60) + "m"
    updating = false
}

let previousUrl = "";

const observer = new MutationObserver(() => {

    if (window.location.href !== previousUrl) {
        previousUrl = window.location.href;
        if (window.location.href === "https://kirka.io/hub/clans/champions-league") {
            isClanWarPage = true
        } else {
            isClanWarPage = false
            updating = false
        }
    }

    if (isClanWarPage) {
        if (document.getElementsByClassName("reset-time")[0]) {
            if (!document.getElementsByClassName("reset-time")[0].innerText.includes("d") || !document.getElementsByClassName("reset-time")[0].innerText.includes("h") || !document.getElementsByClassName("reset-time")[0].innerText.includes("m")) {
                if (!updating) {
                    updating = true;
                    clanWarUsers();
                }
            }
        }
    }

    if (document.getElementsByClassName("hit")[0] && customHitmarker && settings.get('customHitmarkerLink') && settings.get('customHitmarkerLink') !== '') {
        document.getElementsByClassName("hit")[0].src = settings.get('customHitmarkerLink');
    }

});

observer.observe(document, {
    subtree: true,
    childList: true
});




//hp numbers default ingame now
/*const observer = new MutationObserver(function (mutations) {
    mutations.forEach(function (mutation) {
        document.getElementsByClassName('hp-title')[0].innerText = hpNumber ? mutation.target.style.width.slice(0, -1) : "HP";
    });
});*/

let scoped = false;


document.addEventListener('mousedown', (e) => {
    if (e.button === 2) {
        scoped = true;
        inspecting = false;
    }
});

document.addEventListener('mouseup', (e) => {
    if (e.button === 2) scoped = false;
    if (e.button === 3 || e.button === 4) e.preventDefault();

});

let inspectedWeapon;

document.addEventListener('keydown', (e) => {

    if (inspectListening) {
        settings.set('inspectKey', e.key);
        document.getElementById("inspBindButton").innerText = e.key.toUpperCase();
        inspectListening = false;
    }

    if (menuListening) {
        settings.set('menuKey', e.key);
        document.getElementById("menuBindButton").innerText = e.key.toUpperCase();
        menuListening = false;
        toggleGui();
    }

    if (e.key === settings.get("inspectKey").toLowerCase()) {
        inspecting = true;
        setTimeout(() => {
            inspecting = false
        }, 3000);
    }

    if (e.key.toLowerCase() === settings.get("menuKey")?.toLowerCase() || e.key === "PageUp" || e.key === "F8") {
        toggleGui();
    }

});

let redWireframe = 255;
let greenWireframe = 0;
let blueWireframe = 0;

let redHighlight = 255;
let greenHighlight = 0;
let blueHighlight = 0;

setInterval(() => {

    if (rainbow) {
        if (redWireframe > 0 && blueWireframe === 0) {
            redWireframe--;
            greenWireframe++;
        }
        if (greenWireframe > 0 && redWireframe === 0) {
            greenWireframe--;
            blueWireframe++;
        }
        if (blueWireframe > 0 && greenWireframe === 0) {
            redWireframe++;
            blueWireframe--;
        }
    } else {
        let color = hexToRgb("#ff0000");
        redWireframe = color.r;
        greenWireframe = color.g;
        blueWireframe = color.b;
    }

    if (rgbHighlight) {
        if (redHighlight > 0 && blueHighlight === 0) {
            redHighlight--;
            greenHighlight++;
        }
        if (greenHighlight > 0 && redHighlight === 0) {
            greenHighlight--;
            blueHighlight++;
        }
        if (blueHighlight > 0 && greenHighlight === 0) {
            redHighlight++;
            blueHighlight--;
        }
    } else {
        let color = hexToRgb("#00FF00");
        redHighlight = color.r;
        greenHighlight = color.g;
        blueHighlight = color.b;
    }

}, 4);

let armsMaterial;
let playerStructs = {};
let playerList;
const weaponColors = {
    Bayonet: "#AAFFAA",
    Tomahawk: "#AAFFAA",
    Shark: "#31fa31",
    Weatie: "#00FF00",
    Revolver: "#570091",
    LAR: "#ffe15c",
    VITA: "#ff00ea",
    M60: "#00ebff",
    "MAC-10": "#065000",
    "AR-9": "#6a26e0",
    SCAR: "#ff9c08",
}

class Vector3 {
    constructor(x, y, z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}

const defaultPositions = {
    lar: new Vector3(-0.0078, 0.045, 0.0205),
    weatie: new Vector3(0.0009, 0.0541, 0.0577),
    "mac-10": new Vector3(-0.0077, 0.0588, 0),
    vita: new Vector3(0.0095, 0.0673, 0.0733),
    m60: new Vector3(-0.0077, 0.067, 0.0447),
    scar: new Vector3(0.0057, 0.046, 0.0531),
    revolver: new Vector3(-0.0065, 0.065, -0.17),
    "ar-9": new Vector3(-0.0077, 0.067, 0),
    shark: new Vector3(-0.0157, 0.0094, -0.08),
    bayonet: new Vector3(-0.0248, 0.0324, 0.0299),
    tomahawk: new Vector3(-0.0248, 0.0324, 0.0196)
}

class Player {
    constructor(spawnProtected, wName) {
        this.spawnProtected = spawnProtected;
        this.wName = wName;
    }
}


function animate() {

    window.requestAnimationFrame(animate);

    if (menuVisible) {
        if (minPlayerSlider) {
            minPlayers = Number.parseInt(minPlayerSlider.value);
            minPlayersLab.innerText = minPlayerSlider.value + " min. Players";
        }

        if (maxPlayerSlider) {
            maxPlayers = Number.parseInt(maxPlayerSlider.value);
            maxPlayersLab.innerText = maxPlayerSlider.value + " max. Players";
        }

        if (minTimeLeftSlider) {
            minTimeLeft = Number.parseInt(minTimeLeftSlider.value);
            minTimeLeftLab.innerText = minTimeLeftSlider.value + " min. Time Left";
        }

        if (volumeSlider) {
            volume = Number.parseFloat(volumeSlider.value);
            volumeLab.innerText = "Volume: " + volumeSlider.value;
        }
    }

    if (flagMaterial) {
        if (hideFlagAds) {
            flagMaterial.visible = !scoped;
        } else {
            flagMaterial.visible = true;
        }
    }

    if (overlayModel) {
        if (leftHanded) {
            overlayModel.scale.x = -1;
        } else {
            overlayModel.scale.x = 1;
        }
    }

    if (crosshair && permCrosshair) crosshair.style = "visibility: visible !important; opacity: 1 !important; display: block !important; transition: none; !important"


    try {

        let weap = document.getElementsByClassName('list-weapons')[0].children[0].children[0].innerText;
        let num = 4;

        if (weap === "Weatie" || weap === "MAC-10") num = 5;

        if (weap === "AR-9" || weap === "Revolver") num = 3;

        let arms = true;
        if ((scoped && hideWeaponsAds) || hideArms) {
            arms = false;
        }

        const weaponModel = scene["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"]["0"]["_queries"]["player"]["entities"]["0"]["_components"]["35"]["weapons"][weap]?.model;

        const sharkModel = scene["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"]["0"]["_queries"]["player"]["entities"]["0"]["_components"]["35"]["weapons"].Shark?.model;
        const bayonetModel = scene["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"]["0"]["_queries"]["player"]["entities"]["0"]["_components"]["35"]["weapons"].Bayonet?.model;
        const tomahawkModel = scene["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"]["0"]["_queries"]["player"]["entities"]["0"]["_components"]["35"]["weapons"].Tomahawk?.model;

        if (weaponModel?.parent?.children[0]) armsMaterial = weaponModel.parent.children[0].material;

        const weaponMaterial = weaponModel?.children[num].material;
        const sharkMaterial = sharkModel?.children[3]?.material;
        const bayonetMaterial = bayonetModel?.children[1]?.material;
        const tomahawkMaterial = tomahawkModel?.children[1]?.material;


        if (armsMaterial) armsMaterial.visible = arms;

        if (hideWeaponsAds) {

            if (weaponMaterial) weaponMaterial.visible = !scoped;
            if (sharkMaterial) sharkMaterial.visible = !scoped;
            if (bayonetMaterial) bayonetMaterial.visible = !scoped;
            if (tomahawkMaterial) tomahawkMaterial.visible = !scoped;
        }

        if (inspecting) {
            if (!prevInsp) {
                prevInspectPos = weaponModel.position.clone();
                prevInspectRot = weaponModel.rotation.clone();
                if (weaponModel) inspectedWeapon = weaponModel;
            }
            weaponModel.rotation.x = 0;
            weaponModel.rotation.y = -0.3;
            weaponModel.rotation.z = -0.4;

            weaponModel.position.y = 0.05;
            weaponModel.position.z = -0.08;
        } else {
            if (prevInsp) {
                inspectedWeapon.rotation.x = prevInspectRot.x;
                inspectedWeapon.rotation.y = prevInspectRot.y;
                inspectedWeapon.rotation.z = prevInspectRot.z;

                inspectedWeapon.position.y = prevInspectPos.y;
                inspectedWeapon.position.z = prevInspectPos.z;
            }
        }

        prevInsp = inspecting;

        if (wireframeArms && armsMaterial) {
            setWireframe(true, armsMaterial);
        } else if (prevWireframeArms && armsMaterial) {
            setWireframe(false, armsMaterial);
        }

        if (wireframeWeapons) {
            if (weaponMaterial) setWireframe(true, weaponMaterial);
            if (sharkMaterial) setWireframe(true, sharkMaterial);
            if (bayonetMaterial) setWireframe(true, bayonetMaterial);
            if (tomahawkMaterial) setWireframe(true, tomahawkMaterial);
        } else if (prevWireframeWeapons) {
            if (weaponMaterial) setWireframe(false, weaponMaterial);
            if (sharkMaterial) setWireframe(false, sharkMaterial);
            if (bayonetMaterial) setWireframe(false, bayonetMaterial);
            if (tomahawkMaterial) setWireframe(false, tomahawkMaterial);
        }

        prevWireframeWeapons = wireframeWeapons;
        prevWireframeArms = wireframeArms;

    } catch {
    }

    try {

        try {
            playerStructs = {}

            if (playerList?.$items) {

                for (let key of playerList.$items.keys()) {
                    const e = playerList?.$items.get(key);
                    if (e && e.sessionId) playerStructs[e.sessionId] = new Player(e.spawnProtected, e.wName);
                }

                /*for (let i = 0; i < playerList.$items.size; i++) {
                    const e = playerList?.$items[i];
                    console.log(e)
                    if (e && e.sessionId) playerStructs[e.sessionId] = new Player(e.spawnProtected, e.wName);
                }*/
            }
        } catch {
        }


        let localPlayerClass = scene["children"]["0"]["parent"]["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"]["0"]["_queries"]["player"]["entities"]["0"]["_components"]["38"].wnWmN;

        let qNum = 2;

        if (!scene["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"]["2"]["_queries"].players) qNum = 3;

        for (let i = 0; i < scene["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"][qNum]["_queries"].players.entities.length; i++) {

            let player = scene["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"][qNum]["_queries"].players.entities[i]["_components"];
            let mat = scene["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"][qNum]["_queries"].players.entities[i]["_components"][0].value.children[0].children[0].children[1].material;

            if (!playerHighLight) continue;

            let color = hexToRgb("#0000ff");
            if (!localPlayerClass.team || localPlayerClass.team !== player["50"].team) {
                color = hexToRgb("#00FF00");
                if (weaponHighlighter) color = hexToRgb(weaponColors[playerStructs[player["50"].sessionId].wName]);
                if (playerStructs[player["50"].sessionId].spawnProtected) color = hexToRgb('#ff2222');
            }

            let r = (rgbHighlight ? redHighlight : color.r) / 255;
            let g = (rgbHighlight ? greenHighlight : color.g) / 255;
            let b = (rgbHighlight ? blueHighlight : color.b) / 255;

            let matCpy = mat.clone();

            matCpy.map = null;

            matCpy.color.r = r;
            matCpy.color.g = g;
            matCpy.color.b = b;

            matCpy.needsUpdate = true;

            scene["entity"]["_entityManager"]["mWnwM"]["systemManager"]["_systems"][qNum]["_queries"].players.entities[i]["_components"][0].value.children[0].children[0].children[1].material = matCpy;

        }
    } catch {
    }

}

animate();


window.XMLHttpRequest = class extends window.XMLHttpRequest {

    get responseText() {
        if (this.invReq) {
            this.invReq = false;
            let entries = JSON.parse(this.responseText);
            let sortedItems = {mythical: [], legendary: [], epic: [], rare: [], common: []};

            for (let entry of entries) {
                sortedItems[entry.item.rarity.toLowerCase()].push(entry);
            }

            let editEntries = [];
            for (let rarity in sortedItems) {
                editEntries = [].concat(editEntries, sortedItems[rarity]);
            }

            return JSON.stringify(editEntries);
        }

        return super.responseText;
    }

    open(method, url) {
        if (url === "https://api.kirka.io/api/inventory") this.invReq = true;
        return super.open(...arguments);
    }
}


function minutesLeft(e) {
    return Math.ceil((480 - (Date.now() - Date.parse(e)) / 1000));
}

document.onkeydown = event => {
    if (event.key === "F8" && autoJoin) {
        responseCount = 0;
        allLobbyData = [];

        fetch('https://eu1.kirka.io/matchmake')
            .then(response => response.json())
            .then(dataEU => {

                for (let i = 0; i < dataEU.length; i++) {
                    dataEU[i].region = "EU";
                }
                if (euLobbies) {
                    for (let i = 0; i < dataEU.length; i++) {
                        allLobbyData.push(dataEU[i]);
                    }
                }
                responseCount++;
                checkSearchLobby();
            });
        fetch('https://na1.kirka.io/matchmake')
            .then(response => response.json())
            .then(dataNA => {

                for (let i = 0; i < dataNA.length; i++) {
                    dataNA[i].region = "NA";
                }
                if (naLobbies) {
                    for (let i = 0; i < dataNA.length; i++) {
                        allLobbyData.push(dataNA[i]);
                    }
                }
                responseCount++;
                checkSearchLobby();
            });
        fetch('https://asia1.kirka.io/matchmake')
            .then(response => response.json())
            .then(dataASIA => {

                for (let i = 0; i < dataASIA.length; i++) {
                    dataASIA[i].region = "ASIA";
                }
                if (asiaLobbies) {
                    for (let i = 0; i < dataASIA.length; i++) {
                        allLobbyData.push(dataASIA[i]);
                    }
                }
                responseCount++;
                checkSearchLobby();
            });
    }
}

function checkSearchLobby() {
    if (responseCount < 3) return;

    console.log(allLobbyData);

    if (parkourLobbies) {
        gameModes.push('ParkourRoom');
    }
    if (ffaLobbies) {
        gameModes.push('DeathmatchRoom');
    }
    if (tdmLobbies) {
        gameModes.push('TeamDeathmatchRoom');
    }

    let fittingLobbies = [];
    for (let i = 0; i < allLobbyData.length; i++) {
        if (allLobbyData[i].metadata.custom === true && !customGames) continue;
        if (allLobbyData[i].locked === false && allLobbyData[i].clients >= minPlayers && allLobbyData[i].clients <= maxPlayers && gameModes.includes(allLobbyData[i].name) && minutesLeft(allLobbyData[i].createdAt) >= minTimeLeft && (maps.includes(allLobbyData[i].metadata.mapName.toLowerCase()) || !filterMaps)) {
            if (avoidSameLobby) {
                if (!currentURL.includes(allLobbyData[i].roomId)) {
                    fittingLobbies.push(allLobbyData[i]);
                }
            } else {
                fittingLobbies.push(allLobbyData[i]);
            }
        }
    }

    if (fittingLobbies.length !== 0) {
        bestLobby = fittingLobbies[0];
        if (fittingLobbies.length > 0) {
            for (let i = 0; i < fittingLobbies.length; i++) {
                if (bestLobby.clients < fittingLobbies[i].clients) {
                    bestLobby = fittingLobbies[i];
                } else if (bestLobby.clients === fittingLobbies[i].clients) {
                    if (minutesLeft(bestLobby.createdAt) < minutesLeft(fittingLobbies[i].createdAt)) {
                        bestLobby = fittingLobbies[i];
                    }
                }
            }
        }
    } else if (preferredFilter === 'Time') {
        bestLobby = fittingLobbies[0];
        if (fittingLobbies.length > 0) {
            for (let i = 0; i < fittingLobbies.length; i++) {
                if (minutesLeft(bestLobby.createdAt) < minutesLeft(fittingLobbies[i].createdAt)) {
                    bestLobby = fittingLobbies[i];
                }
            }
        }
    }
    if (fittingLobbies.length !== 0 && bestLobby !== '') {
        let joinURL = 'https://kirka.io/games/' + bestLobby.region + '~' + bestLobby.roomId;
        window.location.href = joinURL;
    } else alert('No Lobby found - consider changing your settings'); //popup ohne alert?
}


Object.defineProperty(Object.prototype, '_players', {
    set(v) {
        this._p = v;
        playerList = v;
    },
    get() {
        return this._p;
    }
});

let oldDefine = Object.defineProperty;
Object.defineProperty = (...args) => {
    if (args[0] && args[1] && args[1] === 'renderer' && args[0].constructor.name.startsWith('_0x')) {
        if (args[0].WnNMwm) {
            Object.defineProperty(args[0].camera, "fov", {
                get() {
                    let returnValue = Number.parseInt(args[0].WnNMwm.fov);
                    if (!adspower && this.vFov) returnValue = this.vFov;
                    return returnValue;
                },
                set(v) {
                    this.vFov = v;
                }
            });
        }
    }
    return oldDefine(...args);
}

Object.defineProperty(Object.prototype, 'gain', {
    set(v) {
        if (v.gain) {
            v.gain.value = volume;
            gains.push(v.gain);
        }
        this._v = v;
    },
    get() {
        return this._v;
    }
});

Object.defineProperty(Audio.prototype, 'muted', {
    set(v) {
    },
    get() {
        return noKillSound;
    }
});


function setWireframe(bool, material) {
    material.wireframe = bool;
    material.color.r = bool ? redWireframe / 255 : 1;
    material.color.g = bool ? greenWireframe / 255 : 1;
    material.color.b = bool ? blueWireframe / 255 : 1;
}


function toggleGui() {
    menuVisible = !menuVisible;
    if (menuVisible) {
        document.exitPointerLock();
        gui.style.display = 'inline-block';
    } else {
        gui.style.display = 'none';
    }
    settings.set('menuOpen', menuVisible);
}

function hexToRgb(hex) {
    let result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}
