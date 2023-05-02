import jsdom from 'jsdom';
import { util } from './utils.mjs';

const find = {
    paratexts: (xmlDoc,name) => xmlDoc.querySelectorAll(`seg[function~="${name}"], desc[type~="${name}"]`),
    colophons: (xmlDoc) => {
        const colophons = [...xmlDoc.querySelectorAll('colophon, seg[function~="colophon"]')];
        const cs1 = [...xmlDoc.querySelectorAll('desc[type~="copy-statement"]')];
        const cs2 = [...xmlDoc.querySelectorAll('seg[function~="copy-statement"]')].filter( 
            el => !el.closest('colophon, seg[function~="colophon"]')
        );
        return colophons.concat(cs1, cs2);
    },

    cote: (xmlDoc) => {
        const txt = xmlDoc.querySelector('idno[type="shelfmark"]').textContent || '';
        const sort = txt.replace(/\d+/g,((match) => {
            return match.padStart(4,'0');
        }));
        return {text: txt, sort: sort};
    },

    altcotes: (xmlDoc) => {
        const par = xmlDoc.querySelector('idno[type="alternate"]');
        if(!par) return [];
        return par.querySelectorAll('idno');
    },

    collectors: (xmlDoc) => {
        const els = [...xmlDoc.querySelectorAll('persName[role~="collector"]')];
        return new Set(els.map(e => 
            e.hasAttribute('key') ? e.getAttribute('key') : e.textContent
            )
        );
    },

    material: (xmlDoc) => {
        const el = xmlDoc.querySelector('supportDesc');
        if(!el) return;
        const m = el.getAttribute('material');
        if(!m) return;
        const materials = new Map([['palm-leaf','palm leaf'],['palm-leaf talipot','palm leaf (talipot)'],['palm-leaf palmyra','palm leaf (palmyra)'],['paper','paper'],['paper handmade','paper (handmade)'],['paper industrial','paper (industrial)'],['paper laid', 'paper (laid)'],['birch-bark','birch bark'],['copper','copper'],['sancipat','sancipat']]);
        return materials.get(m);
    },

    extent: (xmlDoc) => {
        const folios = xmlDoc.querySelector('measure[unit="folio"]');
        if(folios) {
            const num = folios.getAttribute('quantity');
            const unit = num > 1 ? ' ff.' : ' f.';
            return [num*2, num + unit];
        }
        const pages = xmlDoc.querySelector('measure[unit="page"]');
        if(pages) {
            const num = pages.getAttribute('quantity');
            const unit = num > 1 ? ' pp.' : ' p.';
            return [num, num + unit];
        }
        const plates = xmlDoc.querySelector('measure[unit="plate"]');
        if(plates) {
            const num = plates.getAttribute('quantity');
            const unit = num > 1 ? ' plates' : ' plate';
            return [num, num + unit];
        }
        return '';
    },
    
    dimension: (xmlDoc,type,dim) => {
        const el = xmlDoc.querySelector(`dimensions[type="${type}"] > ${dim}`);
        if(!el) return '';
        const q = el.getAttribute('quantity');
        if(q) return q;
        const min = el.getAttribute('min') || '';
        const max = el.getAttribute('max') || '';
        if(min || max) return `${min}-${max}`;
        return '';
    },

    date: (xmlDoc) => {
        const el = xmlDoc.querySelector('origDate');
        if(!el) return ['','0'];
        const w = el.getAttribute('when');
        if(w) return [w,w];
        const notB = el.getAttribute('notBefore');
        const notA = el.getAttribute('notAfter');
        if(notB || notA)
            return [[notB,notA].join('—'),(notB || notA)]; 
        else return ['','0'];
    },

    images: (xmlDoc) => {
        const el = xmlDoc.querySelector('facsimile > graphic');
        if(!el) return '';
        const url = el.getAttribute('url');
        const dom = new jsdom.JSDOM('<!DOCTYPE html>');
        const a = dom.window.document.createElement('a');
        a.href = url;
        a.appendChild(dom.window.document.createTextNode(a.hostname));
        return a.innerHTML;
    },

    repo: (xmlDoc) => {
        const names = new Map([
            ['Bibliothèque nationale de France. Département des Manuscrits','BnF'],
            ['Bibliothèque nationale de France. Département des Manuscrits.','BnF'],
            ['Biblioteca Apostolica Vaticana','Vatican'],
            ['Bibliothèque nationale et universitaire de Strasbourg','Bnu Strasbourg'],
            ['Staats- und UniversitätsBibliothek Hamburg Carl von Ossietzky','Hamburg Stabi'],
            ['Bodleian Library, University of Oxford','Oxford'],
            ['Cambridge University Library','Cambridge'],
            ['Bibliothèque universitaire des langues et civilisations','BULAC'],
            ['Shri Lal Bahadur Shastri National Sanskrit University','SLBSNS'],
            ['Private collection','private']
        ]);
        const repo = xmlDoc.querySelector('repository > orgName').textContent.replace(/\s+/g,' ');
        return names.get(repo); 
    },
    
    languages: (xmlDoc) => {
        const isocodes = new Map([
            ['ara','Arabic'],
            ['bod','Tibetan'],
            ['eng','English'],
            ['fra','French'],
            ['deu','German'],
            ['hin','Hindi'],
            ['lat','Latin'],
            ['mal','Malayalam'],
            ['mar','Marathi'],
            ['pli','Pali'],
            ['por','Portuguese'],
            ['pra','Prakrit'],
            ['san','Sanskrit'],
            ['sin','Sinhalese'],
            ['tam','Tamil'],
            ['tel','Telugu']
        ]);
        const langs = [...xmlDoc.querySelectorAll('textLang')].reduce((acc,cur) => {
            const main = cur.getAttribute('mainLang') || '';
            const other = cur.getAttribute('otherLangs') || '';
            const codes = [ ...main.split(' '), ...other.split(' ') ];
            for(const code of codes) acc.add(code);
            return acc;
        },new Set());

        return [...langs].filter(e=>e).map(code => isocodes.get(code)).sort().join(', ');
    },
    tbcs: (xmlDoc) => xmlDoc.querySelectorAll('seg[function="TBC"]'),

    title: (xmlDoc) => {
        return xmlDoc.querySelector('titleStmt').querySelector('title').textContent.replace(/&/g,'&#38;').trim()
    },

    persnames: (xmlDoc) => {
        return [...xmlDoc.querySelectorAll('persName')]
            .filter(el => !el.closest('editionStmt') && !el.closest('editor') && !el.closest('bibl') && !el.closest('change'))
            .map(el => {
                return {
                    name: el.hasAttribute('key') ? el.getAttribute('key') : el.textContent,//el.innerHTML, 
                    role: el.getAttribute('role') || ''
                };
            });
    },

    authors: (xmlDoc) => {
        return [...xmlDoc.querySelectorAll('author')]
            .filter(el => !el.closest('bibl'))
            .map(el => {return {name: el.innerHTML, role: 'author'};});
    },

    scribes: (xmlDoc) => {
        const els = [...xmlDoc.querySelectorAll('handNote[scribeRef]')];
        const scribes = new Map([
            ['#ArielTitleScribe','Ariel\'s title scribe'],
            ['#EdouardAriel','Édouard Ariel'],
            ['#PhEDucler','Philippe Étienne Ducler'],
            ['#DuclerScribe','Ducler\'s scribe'],
            ['#UmraosinghShergil','Umraosingh Sher-Gil']
        ]);
        return els.map(el => scribes.get(el.getAttribute('scribeRef')))
            .filter(el => el !== undefined)
            .map(el => {return {name: el, role: 'scribe'}});
    },
    allpersons: () => {
        const cache = new Map();

        return (xmlDoc) => {
            //const peeps = [...find.scribes(xmlDoc),...find.persnames(xmlDoc),...find.authors(xmlDoc)];
            const peeps = [...find.scribes(xmlDoc),...find.persnames(xmlDoc)];

            const peepReducer = function(prevs, cur) {
                if(cache.has(cur.name))
                    cur.name = cache.get(cur.name);
                else {
                    const canonicalname = util.personlookup(cur.name);
                    if(canonicalname) {
                        cache.set(cur.name,canonicalname);
                        cur.name = canonicalname;
                    }
                    else cache.set(cur.name,cur.name);
                }

                for(const prev of prevs) {
                    if(cur.name === prev.name && cur.role === prev.role)
                        return prevs;
                }

                return [...prevs,cur];
            };

            return peeps.reduce(peepReducer,[]);
        };
    },
};

export { find };
