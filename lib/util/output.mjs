import fs from 'fs';
import xlsx from 'xlsx';
import SaxonJS from 'saxon-js';
import { util, make, check } from './utils.mjs';
import { Sanscript } from '../js/sanscript.mjs';
//import Hypher from '../js/hypher.mjs';
//import { hyphenation_ta_Latn } from '../js/ta-Latn.mjs';

//const hyphenator = new Hypher(hyphenation_ta_Latn);

// filepaths are relative to where the main script is run from
const xsltSheet = fs.readFileSync('./lib/util/xslt/tei-to-html-reduced.json',{encoding:'utf-8'});
const templatestr = fs.readFileSync('./lib/util/template.html',{encoding:'utf8'});
const descriptions = make.html(fs.readFileSync('./lib/util/descriptions.html',{encoding:'utf8'}));

const transliterate = (txt,cleaner = false) => {
    const cleaned = txt.replace(/[\n\s]+/g,' ').replace(/\s?%nobreak%/g,'');
    const cleaned2 = cleaner ? cleaned.replace(/[|•-]|=(?=\w)/g,'') : cleaned;
    const transliterated = Sanscript.t(cleaned2.trim(), 'tamil','iast')
                .replace(/^⁰|([^\d⁰])⁰/g,'$1¹⁰')
                .replace(/l̥/g,'ḷ');
    return transliterated;
    // need to mark language of text, and hyphenate only text nodes
    //return hyphenator.hyphenateText(transliterated);
}

const output = {
    index: (data, opts) => {
        const isMSPart = (str) => {
            const dot = /\d\.\d/.test(str);
            const letter = /\d[a-z]$/.test(str);
            if(dot && letter) return ' class="subsubpart"';
            if(dot || letter) return ' class="subpart"';
            else return '';
        };
        const template = make.html(templatestr);
        const title = template.querySelector('title');
        const ptitle = opts && opts.name ? opts.name[0].toUpperCase() + opts.name.slice(1) : 'Manuscripts';
        title.textContent = `${title.textContent}: ${ptitle}`;
        const prefix_sanitized = opts?.prefix?.replace(/\s/g,'_');
        const pdesc = prefix_sanitized ? descriptions.getElementById(prefix_sanitized) : null;
        if(pdesc) template.querySelector('article').prepend(pdesc);
        const table = template.getElementById('index');
        const thead = opts && opts.prefix ? 
            make.header(['Old Shelfmark','New Shelfmark','Repository','Title','Languages','Material','Extent','Date','Images']) :
            make.header(['Shelfmark','Repository','Title','Languages','Material','Extent','Date','Images']);

        const tstr = data.reduce((acc, cur) => {

            const poststr = 
`  <td>${cur.repo}</td>
  <td>${cur.title}</td>
  <td>${cur.languages}</td>
  <td>${cur.material}</td>
  <td data-content="${cur.extent[0]}">${cur.extent[1]}</td>
  <td data-content="${cur.date[1]}">${cur.date[0]}</td>
  <td class="smallcaps">${cur.images}</td>
</tr>`;

            if(!opts || !opts.prefix) {
                return acc +            
`<tr>
  <th data-content="${cur.cote.sort}"${isMSPart(cur.cote.text)}><a href="${cur.fname}">${cur.cote.text}</a></th>` + poststr;
            }

            // with prefix
            const oldcote = ((idnos) => {
                for(const idno of idnos) {
                    const txt = idno.textContent;
                    if(txt.startsWith(opts.prefix))
                        return txt;
                }
                return '';
            })(cur.altcotes);

            const hascollector = (() => {
                if(!opts || !opts.keys) return false;
                for(const key of opts.keys)
                    if(cur.collectors.has(key)) return true;
                return false;
            })();

            if(!oldcote && !hascollector) return acc;

            const oldsort = oldcote.replace(/\d+/g,((match) => {
                return match.padStart(4,'0');
            }));
            return acc +
`<tr>
  <th data-content="${oldsort}"${isMSPart(cur.cote.text)}>${oldcote}</th>
  <td data-content="${cur.cote.sort}"${isMSPart(cur.cote.text)}><a href="${cur.fname}">${cur.cote.text}</a></td>` + poststr;
        },'');

    table.innerHTML = `${thead}<tbody>${tstr}</tbody>`;

    /*
    const ths = table.querySelectorAll('th');
    ths[0].classList.add('sorttable_alphanum');
    if(opts && opts.prefix) ths[1].classList.add('sorttable_alphanum');
    */

    const fname = prefix_sanitized ?
        prefix_sanitized.toLowerCase() + '.html' :
        'index.html';
    fs.writeFileSync(`../${fname}`,template.documentElement.outerHTML,{encoding: 'utf8'});
    },

    ariel: (data) => {
        const isMSPart = (str) => {
            const dot = /\d\.\d/.test(str);
            const letter = /\d[a-z]$/.test(str);
            if(dot && letter) return ' class="subsubpart"';
            if(dot || letter) return ' class="subpart"';
            else return '';
        };
        const template = make.html(templatestr);
        const title = template.querySelector('title');
        const ptitle = 'Ariel collection';
        title.textContent = `${title.textContent}: ${ptitle}`;
        const pdesc = descriptions.getElementById('Ariel');
        if(pdesc) template.querySelector('article').prepend(pdesc);
        const table = template.getElementById('index');
        const thead = make.header(['Old Shelfmark','Older Shelfmark','New Shelfmark','Repository','Title','Languages','Material','Extent','Date','Images']);

        const tstr = data.reduce((acc, cur) => {

            const poststr = 
`  <td>${cur.repo}</td>
  <td>${cur.title}</td>
  <td>${cur.languages}</td>
  <td>${cur.material}</td>
  <td data-content="${cur.extent[0]}">${cur.extent[1]}</td>
  <td data-content="${cur.date[1]}">${cur.date[0]}</td>
  <td class="smallcaps">${cur.images}</td>
</tr>`;

            const [oldcote,oldercote] = ((idnos) => {
                var old1 = '';
                var old2 = '';
                for(const idno of idnos) {
                    const txt = idno.textContent;
                    if(txt.startsWith('Ariel'))
                        old1 = txt;
                    else if(txt.match(/^\w\/\d+$/))
                        old2 = txt;
                }
                return [old1,old2];
            })(cur.altcotes);

            const hascollector = (() => {
                for(const key of ['Édouard Ariel','Ariel, Édouard'])
                    if(cur.collectors.has(key)) return true;
                return false;
            })();

            if(!oldcote && !hascollector) return acc;

            const oldsort = oldcote.replace(/\d+/g,((match) => {
                return match.padStart(4,'0');
            }));
            const oldersort = oldercote.replace(/\d+/g,((match) => {
                return match.padStart(4,'0');
            }));

            return acc +
`<tr>
  <th data-content="${oldsort}"${isMSPart(cur.cote.text)}>${oldcote}</th>
  <td data-content="${oldersort}">${oldercote}</td>
  <td data-content="${cur.cote.sort}"${isMSPart(cur.cote.text)}><a href="${cur.fname}">${cur.cote.text}</a></td>` + poststr;
        },'');

    table.innerHTML = `${thead}<tbody>${tstr}</tbody>`;

    fs.writeFileSync('../ariel.html',template.documentElement.outerHTML,{encoding: 'utf8'});
    },

    paratexts: (data, opts) => {
        
        const ptitle = opts.name ? opts.name[0].toUpperCase() + opts.name.slice(1) : 'Paratexts';
        const prefix_sanitized = opts?.name?.replace(/\s/g,'_');
        const pdesc = prefix_sanitized ? descriptions.getElementById(prefix_sanitized) : null;
        const pprop = opts.prop;
        const pfilename = opts.name.replace(/\s+/g, '_') + '.html';
    
        const predux = function(acc,cur,cur1) {
            
            const ret = util.innertext(cur);
            const inner = ret.inner;
            const placement = ret.placement;
            const synch = ret.synch;
            const milestone = ret.facs ?
                `<a href="${cur1.fname}?facs=${ret.facs}">${ret.milestone}</a>` :
                ret.milestone;

            const unit = synch ? synch.replace(/#/g,'') : '';
            const processed = SaxonJS.transform({
                stylesheetText: xsltSheet,
                sourceText: '<TEI xmlns="http://www.tei-c.org/ns/1.0">'+inner+'</TEI>',
                destination: 'serialized'},'sync');
            const res = processed.principalResult || '';
            const txt = transliterate(res);
            const clean = make.html(`<html>${txt}</html>`).documentElement.textContent.trim();
            return acc + 
                `<tr>
                <td data-content="${clean}">
                ${txt}
                </td>
                <td><a href="${cur1.fname}">${cur1.cote.text}</a></td>
                <td>
                ${cur1.repo}
                </td>
                <td>
                ${cur1.title}
                </td>
                <td>
                ${unit}
                </td>
                <td>
                ${milestone}
                </td>
                <td>
                ${placement}
                </td>
                </tr>\n`;
        };
        
        const template = make.html(templatestr);

        const title = template.querySelector('title');
        title.textContent = `${title.textContent}: ${ptitle}`;

        if(pdesc) template.querySelector('article').prepend(pdesc);

        const table = template.getElementById('index');
        const tstr = data.reduce((acc, cur) => {
            if(cur[pprop].length > 0) {
                const lines = [...cur[pprop]].reduce((acc2,cur2) => predux(acc2,cur2,cur),'');
                return acc + lines;
            }
            else return acc;
        },'');
        const singular = ptitle.replace(/s$/,'');
        const thead = make.header([singular,'Shelfmark','Repository','Title','Unit','Page/folio','Placement']);
        table.innerHTML = `${thead}<tbody>${tstr}</tbody>`;
        table.querySelector('thead th').dataset.sort = 'sortTamil';
        //table.querySelectorAll('th')[1].classList.add('sorttable_alphanum');
        fs.writeFileSync(`../${pfilename}`,template.documentElement.outerHTML,{encoding: 'utf8'});
    },
   
    xslx: (data,opts) => {

        const xslx_Sheet = fs.readFileSync('./lib/util/xslt/blessings-xlsx.json',{encoding:'utf-8'});
        const xslx_Sheet_clean = fs.readFileSync('./lib/util/xslt/blessings-xlsx-clean.json',{encoding:'utf-8'});
        const xlsxredux = function(acc,cur,cur1) {
            
            const ret = util.innertext(cur);
            const inner = ret.inner;
            const placement = ret.placement;
            const milestone = ret.milestone;
            const synch = ret.synch;

            const unit = synch ? synch.replace(/#/g,'') : '';

            const processed = SaxonJS.transform({
                stylesheetText: xslx_Sheet,
                sourceText: '<TEI xmlns="http://www.tei-c.org/ns/1.0">'+inner+'</TEI>',
                destination: 'serialized'},'sync');
            const processed2 = SaxonJS.transform({
                stylesheetText: xslx_Sheet_clean,
                sourceText: '<TEI xmlns="http://www.tei-c.org/ns/1.0">'+inner+'</TEI>',
                destination: 'serialized'},'sync');
            const txt = transliterate(processed.principalResult);
            const cleantxt = transliterate(processed2.principalResult,true);
            const tunai = Array.from(cleantxt.matchAll(/tuṇai/g)).length;
            
            return acc + `<tr><td>${txt}</td><td>${cleantxt}</td><td>${cur1.cote.text}</td><td>${cur1.repo}</td><td>${cur1.title}</td><td>${unit}</td><td>${milestone}</td><td>${placement}</td><td>${tunai}</td></tr>`;
        };

        const xslxdoc = make.html('');
        const htmltab = xslxdoc.createElement('table');
        const tabbod = xslxdoc.createElement('tbody');
        const xslxstr = data.reduce((acc, cur) => {
            if(cur[opts.prop].length > 0) {
                const lines = [...cur[opts.prop]].reduce((acc2,cur2) => xlsxredux(acc2,cur2,cur),'');
                return acc + lines;
            }
            else return acc;
        },'');
        tabbod.innerHTML = xslxstr;
        htmltab.appendChild(tabbod);
        const wb = xlsx.utils.book_new();
        const ws = xlsx.utils.table_to_sheet(htmltab);
        xlsx.utils.book_append_sheet(wb,ws,opts.name);
        xlsx.writeFile(wb,`../${opts.name}.xlsx`);
    },

    colophons: (data) => {
        const colophonredux = function(acc,cur,cur1) {
            
            const ret = util.innertext(cur);
            const inner = ret.inner;
            const placement = ret.placement;
            const unit = ret.synch ? ret.synch.replace(/#/g,'') : '';
            const milestone = ret.facs ?
                `<a href="${cur1.fname}?facs=${ret.facs}">${ret.milestone}</a>` :
                ret.milestone;

            const processed = SaxonJS.transform({
                stylesheetText: xsltSheet,
                sourceText: '<TEI xmlns="http://www.tei-c.org/ns/1.0">'+inner+'</TEI>',
                destination: 'serialized'},'sync');
            const res = processed.principalResult || '';
            const txt = transliterate(res);
            const clean = make.html(`<html>${txt}</html>`).documentElement.textContent.trim();
            return acc + 
        `<tr>
        <td data-content="${clean}">
        ${txt}
        </td>
        <td><a href="${cur1.fname}">${cur1.cote.text}</a></td>
        <td>
        ${cur1.repo}
        </td>
        <td>
        ${cur1.title}
        </td>
        <td>
        ${unit}
        </td>
        <td>
        ${milestone}
        </td>
        </tr>\n`;
        };

        const template = make.html(templatestr);

        const title = template.querySelector('title');
        title.textContent = `${title.textContent}: Colophons`;
        
        const pdesc = descriptions.getElementById('colophons');
        if(pdesc) template.querySelector('article').prepend(pdesc);

        const thead = make.header(['Colophon','Shelfmark','Repository','Title','Unit','Page/Folio']);
        const tstr = data.reduce((acc, cur) => {
            if(cur.colophons.length > 0) {
                const lines = [...cur.colophons].reduce((acc2,cur2) => colophonredux(acc2,cur2,cur),'');
                return acc + lines;
            }
            else return acc;
        },'');

        const table = template.getElementById('index');
        table.innerHTML = `${thead}<tbody>${tstr}</tbody>`;
        table.querySelector('thead th').dataset.sort = 'sortTamil';
        //table.querySelectorAll('th')[1].classList.add('sorttable_alphanum');

        fs.writeFileSync('../colophons.html',template.documentElement.outerHTML,{encoding: 'utf8'});
    },
    /*
    invocations: (data) => {
        
        const predux = function(acc,cur,cur1) {
            
            const ret = util.innertext(cur);
            const inner = ret.inner;
            const placement = ret.placement;
            const milestone = ret.facs ?
                `<a href="${cur1.fname}?facs=${ret.facs}">${ret.milestone}</a>` :
                ret.milestone;
            const synch = ret.synch;
            const unit = synch ? synch.replace(/#/g,'') : '';
            const types = util.functions(cur);
            const is_satellite = types.has('satellite-stanza') ? '✓' : '';

            const processed = SaxonJS.transform({
                stylesheetText: xsltSheet,
                sourceText: '<TEI xmlns="http://www.tei-c.org/ns/1.0">'+inner+'</TEI>',
                destination: 'serialized'},'sync');
            const res = processed.principalResult || '';
            const txt = transliterate(res);
            const clean = make.html(`<html>${txt}</html>`).documentElement.textContent.trim();
            return acc + 
                `<tr>
                <td data-content="${clean}">
                ${txt}
                </td>
                <td><a href="${cur1.fname}">${cur1.cote.text}</a></td>
                <td>
                ${cur1.repo}
                </td>
                <td>
                ${cur1.title}
                </td>
                <td>
                ${unit}
                </td>
                <td>
                ${milestone}
                </td>
                <td>
                ${placement}
                </td>
                <td>
                ${is_satellite}
                </td>
                </tr>\n`;
        };
        
        const template = make.html(templatestr);

        const title = template.querySelector('title');
        title.textContent = `${title.textContent}: Invocations`;

        const pdesc = descriptions.getElementById('invocations');
        if(pdesc) template.querySelector('article').prepend(pdesc);

        const table = template.getElementById('index');
        const tstr = data.reduce((acc, cur) => {
            const props = [...cur.invocations];
            if(props.length > 0) {
                const lines = props.reduce((acc2,cur2) => predux(acc2,cur2,cur),'');
                return acc + lines;
            }
            else return acc;
        },'');
        const thead = make.header(['Invocation','Shelfmark','Repository','Title','Unit','Page/folio','Placement','Satellite stanza']);
        table.innerHTML = `${thead}<tbody>${tstr}</tbody>`;
        table.querySelector('thead th').dataset.sort = 'sortTamil';
        //table.querySelectorAll('th')[1].classList.add('sorttable_alphanum');
        fs.writeFileSync('../invocations.html',template.documentElement.outerHTML,{encoding: 'utf8'});
    },
    satellite: (data) => {
        
        const predux = function(acc,cur,cur1) {
            
            const ret = util.innertext(cur);
            const inner = ret.inner;
            const placement = ret.placement;
            const milestone = ret.facs ?
                `<a href="${cur1.fname}?facs=${ret.facs}">${ret.milestone}</a>` :
                ret.milestone;
            const synch = ret.synch;
            const unit = synch ? synch.replace(/#/g,'') : '';
            const types = util.functions(cur);
            const is_invocation = types.has('invocation') ? '✓' : '';

            const processed = SaxonJS.transform({
                stylesheetText: xsltSheet,
                sourceText: '<TEI xmlns="http://www.tei-c.org/ns/1.0">'+inner+'</TEI>',
                destination: 'serialized'},'sync');
            const res = processed.principalResult || '';
            const txt = transliterate(res);
            const clean = make.html(`<html>${txt}</html>`).documentElement.textContent.trim();
            return acc + 
                `<tr>
                <td data-content="${clean}">
                ${txt}
                </td>
                <td><a href="${cur1.fname}">${cur1.cote.text}</a></td>
                <td>
                ${cur1.repo}
                </td>
                <td>
                ${cur1.title}
                </td>
                <td>
                ${unit}
                </td>
                <td>
                ${milestone}
                </td>
                <td>
                ${placement}
                </td>
                <td>
                ${is_invocation}
                </td>
                </tr>\n`;
        };
        
        const template = make.html(templatestr);

        const title = template.querySelector('title');
        title.textContent = `${title.textContent}: Satellite Stanzas`;

        const pdesc = descriptions.getElementById('satellite_stanzas');
        if(pdesc) template.querySelector('article').prepend(pdesc);

        const table = template.getElementById('index');
        const tstr = data.reduce((acc, cur) => {
            const props = [...cur.satellites];
            if(props.length > 0) {
                const lines = props.reduce((acc2,cur2) => predux(acc2,cur2,cur),'');
                return acc + lines;
            }
            else return acc;
        },'');
        const thead = make.header(['Satellite stanza','Shelfmark','Repository','Title','Unit','Page/folio','Placement','Invocation']);
        table.innerHTML = `${thead}<tbody>${tstr}</tbody>`;
        table.querySelector('thead th').dataset.sort = 'sortTamil';
        fs.writeFileSync('../satellite_stanzas.html',template.documentElement.outerHTML,{encoding: 'utf8'});
    },
    */
    titles: (data) => {
        
        const predux = function(acc,cur,cur1) {
            const ret = util.innertext(cur);
            const inner = ret.inner;
            const placement = ret.placement;
            const milestone = ret.facs ?
                `<a href="${cur1.fname}?facs=${ret.facs}">${ret.milestone}</a>` :
                ret.milestone;
            const synch = ret.synch;
            const unit = synch ? synch.replace(/#/g,'') : '';
            const title = cur.querySelector('title')?.textContent || '';
            const author = cur.querySelector('persName[role="author"]')?.textContent || '';

            const processed = SaxonJS.transform({
                stylesheetText: xsltSheet,
                sourceText: '<TEI xmlns="http://www.tei-c.org/ns/1.0">'+inner+'</TEI>',
                destination: 'serialized'},'sync');
            const res = processed.principalResult || '';
            const txt = transliterate(res);
            const clean = make.html(`<html>${txt}</html>`).documentElement.textContent.trim();
            return acc + 
                `<tr>
                <td data-content="${clean}">
                ${txt}
                </td>
                <td>
                ${title}
                </td>
                <td>
                ${author}
                </td>
                <td><a href="${cur1.fname}">${cur1.cote.text}</a></td>
                <td>
                ${cur1.repo}
                </td>
                <td>
                ${cur1.title}
                </td>
                <td>
                ${unit}
                </td>
                <td>
                ${milestone}
                </td>
                <td>
                ${placement}
                </td>
                </tr>\n`;
        };
        const template = make.html(templatestr);
        const title = template.querySelector('title');
        title.textContent = `${title.textContent}: Titles`;

        const pdesc = descriptions.getElementById('titles');
        if(pdesc) template.querySelector('article').prepend(pdesc);

        const table = template.getElementById('index');
        const tstr = data.reduce((acc, cur) => {
            const props = [...cur.titles];
            if(props.length > 0) {
                const lines = props.reduce((acc2,cur2) => predux(acc2,cur2,cur),'');
                return acc + lines;
            }
            else return acc;
        },'');
        const thead = make.header(['Title phrase','Title','Author','Shelfmark','Repository','Manuscript title','Unit','Page/folio','Placement']);
        table.innerHTML = `${thead}<tbody>${tstr}</tbody>`;
        table.querySelector('thead th').dataset.sort = 'sortTamil';
        fs.writeFileSync('../titles.html',template.documentElement.outerHTML,{encoding: 'utf8'});
    },
    persons: (data) => {

        const peepredux = function(acc,cur,cur1) {
            const txt = Sanscript.t(
                cur.name.replace(/[\n\s]+/g,' ').trim(),
                'tamil','iast');
            return acc + 
        `<tr>
        <td>
        ${txt}
        </td>
        <td>
        ${cur.role}
        </td>
        <td><a href="${cur1.fname}">${cur1.cote.text}</a></td>
        <td>
        ${cur1.repo}
        </td>
        <td>
        ${cur1.title}
        </td>
        </tr>\n`;
        };
        const template = make.html(templatestr);
        const table = template.getElementById('index');

        const title = template.querySelector('title');
        title.textContent = `${title.textContent}: Persons`;

        const tstr = data.reduce((acc, cur) => {
            if(cur.persons.length > 0) {
                const lines = [...cur.persons].reduce((acc2,cur2) => peepredux(acc2,cur2,cur),'');
                return acc + lines;
            }
            else return acc;
        },'');
        const thead = make.header(['Person','Role','Shelfmark','Repository','Title']);
        table.innerHTML = `${thead}<tbody>${tstr}</tbody>`;
        table.querySelector('thead th').dataset.sort = 'sortTamil';
        //table.querySelectorAll('th')[2].classList.add('sorttable_alphanum');
        fs.writeFileSync('../persons.html',template.documentElement.outerHTML,{encoding: 'utf8'});
    },
    personsnetwork: (data) => {

        const peepmap = function(cur,cur1) {
            const txt = Sanscript.t(
                cur.name.replace(/[\n\s]+/g,' ').trim(),
                'tamil','iast');
            return {
                name: txt,
                role: cur.role,
                fname: cur1.fname,
                cote: cur1.repo + ' ' + cur1.cote.text,
            }
        };

        const bucketgroups = [
            ['author','editor','translator'],
            ['scribe','proofreader','annotator'],
            ['commissioner','owner','collector']
            ];
        const buckets = new Map(bucketgroups.flatMap(el => {
            const bucket = el.join(', ');
            return el.map(role => [role, bucket]);
        }));

        const peepredux = (acc, cur) => {
            
            if(!cur.role) return acc;
            
            const bucket = buckets.has(cur.role) ? buckets.get(cur.role) : 'other';

            if(!acc.has(cur.name))
                acc.set(cur.name, {buckets: new Set([bucket]), roles: new Set([cur.role]), texts: new Set([cur.cote])});
            else {
                const oldrec = acc.get(cur.name);
                oldrec.buckets.add(bucket);
                oldrec.texts.add(cur.cote);
                oldrec.roles.add(cur.role);
            }

            return acc;
        };

        const template = make.html(templatestr);
        template.body.style.margin = '0 auto';
        template.body.style.paddingLeft = '0';
        const section = template.querySelector('section');
        section.innerHTML = '';

        const title = template.querySelector('title');
        title.textContent = `${title.textContent}: Persons`;
        
        const persarr = data.reduce((acc, cur) => {
            if(cur.persons.length > 0) {
                return acc.concat( [...cur.persons].map((cur2) => peepmap(cur2,cur)) );
            }
            else return acc;
        },[]);

        const allpeeps = persarr.reduce(peepredux,new Map());
        
        const links = [];
        const nodes = [];
        const texts = new Set();

        allpeeps.forEach((peep,key) => {
            for(const text of peep.texts) {
                links.push({source: key, target: text, value: 1});
                texts.add(text);
            }
            const roles = [...peep.roles];
            const buckets = [...peep.buckets];
            const node = {id: key, size: peep.texts.size};
            roles.sort();
            node.roles = roles.join(', ');

            if(buckets.length === 1) node.group = buckets[0];
            else {
                buckets.sort();
                node.groups = buckets;
            }
            nodes.push(node);
            });

        for(const text of texts) nodes.push({id: text, group: 'manuscript', roles: 'manuscript'});
       
        const json = JSON.stringify({nodes: nodes, links: links});
        
        const script = template.createElement('script');
        script.setAttribute('type','module');
        script.innerHTML =`
import { makeChart, makeLegend, chartMouseover } from './persons.mjs';
const graph = ${json};
const section = document.querySelector('section');
const svg = makeChart(graph);

const legend = makeLegend(svg.scales.color);

section.appendChild(legend);
section.appendChild(svg);

document.getElementById('spinner').remove();
document.querySelector('section').style.visibility = 'visible';

section.addEventListener('mouseover',chartMouseover);
`
template.body.appendChild(script);
        fs.writeFileSync('../persons-network.html',template.documentElement.outerHTML,{encoding: 'utf8'});
    },
};

export { output };
