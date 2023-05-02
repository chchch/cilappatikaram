import { replaceEl, transliterateTitle, convertFile } from './common.mjs';
import { xml } from '../../../editor/lib/utils.mjs';
import { showSaveFilePicker } from 'https://cdn.jsdelivr.net/npm/native-file-system-adapter/mod.js';

const upload = async (arr) => {
    const files = arr.map(file => {
        const reader = new FileReader();
        return new Promise(res => {
            reader.onload = () => res(reader.result);
            reader.readAsText(file);
        });
    });
    return await Promise.all(files);
};

const main = async () => {
    const tstfile = document.getElementById('tstfile').files[0];
    if(!tstfile) { alert('Missing TST file.'); return; }
    const eadfile = document.getElementById('eadfile').files[0];
    if(!eadfile) { alert('Missing EAD file'); return; }
    
    const [tsttext,eadtext] = await upload([tstfile,eadfile]);
    const xsltres = await fetch('./tei-to-ead.xsl',{encoding: 'utf-8'});
    const xsltSheet = xml.parseString(await xsltres.text());
    
    const tstxml = xml.parseString(tsttext);
    
    const subunits = tstxml.querySelectorAll('msItem[source]');
    const subfiles = [...document.getElementById('subfiles').files];
    const subtexts = await upload(subfiles);
    const subfilemap = new Map();
    for(let i=0;i<subfiles.length;i++)
        subfilemap.set(subfiles[i].name,subtexts[i]);
    
    for(const subunit of subunits) {
        const subfilename = subunit.getAttribute('source');
        const subfile = subfilemap.get(subfilename);
        const subXML = xml.parseString(subfile);
        const subcote = subXML.querySelector('unitid[type="cote"]');
        subcote.setAttribute('type','division'); // change cote to division
        subunit.innerHTML = '';
        const tei = subXML.querySelector('TEI');
        subunit.appendChild(tei);
    }
    
    const indoc = await xml.XSLTransform(xsltSheet,tstxml);
    transliterateTitle(indoc,tstxml);

    const outdoc = xml.parseString(eadtext);
    const newdoc = convertFile(indoc,outdoc);
    
    const file = new Blob([xml.serialize(newdoc)], {type: 'text/xml;charset=utf-u'});
    const filename = eadfile.name.replace(/^\[(.+)\]$/,'$1_TST.xml');
    const fileHandle = await showSaveFilePicker({
        _preferPolyfill: false,
        suggestedName: filename,
        types: [ {description: 'EAD XML', accept: {'application/xml': ['.xml']} } ],
    });
    const writer = await fileHandle.createWritable();
    writer.write(file);
    writer.close();
};

window.addEventListener('load', () => {
    document.getElementById('convertfile').addEventListener('click',main);
});
