import yargs from 'yargs';
import fs from 'fs';
import path from 'path';
import SaxonJS from 'saxon-js';
import jsdom from 'jsdom';
import serializer from 'w3c-xmlserializer';
import { hideBin } from 'yargs/helpers';
import { replaceEl, transliterateTitle, convertFile } from './common.mjs';

const argv = yargs(hideBin(process.argv))
    .option('in', {
        alias: 'i',
        description: 'Input file',
        type: 'string'
    })
    .option('out', {
        alias: 'o',
        description: 'Output file',
        type: 'string'
    })
    .help().alias('help','h').argv;

const parseXML = function(str) {
    const dom = new jsdom.JSDOM('');
    const parser = new dom.window.DOMParser();
    return parser.parseFromString(str,'text/xml');
};

const main = function() {
    const infile = argv.in;
    if(!infile) { console.error('No input file.'); return; }
    const outfile = argv.out;
    if(!outfile) { console.error('No output file.'); return; }
    

    const intext = fs.readFileSync(infile,{encoding: 'utf-8'});
    
    const outtext = (fs.existsSync(outfile)) ?
        fs.readFileSync(outfile,{encoding: 'utf-8'}) : null;
    
    const xsltSheet = fs.readFileSync('tei-to-ead.sef.json',{encoding: 'utf-8'});

    const inxml = parseXML(intext);
    const subunits = inxml.querySelectorAll('msItem[source]');
    for(const subunit of subunits) {
        const dir = path.dirname(infile);
        const subfilename = dir + '/' + subunit.getAttribute('source');
        const subfile = fs.readFileSync(subfilename,{encoding: 'utf-8'});
        const subXML = parseXML(subfile);
        subunit.innerHTML = '';
        const tei = subXML.querySelector('TEI');
        subunit.appendChild(tei);
    }

    const processed = SaxonJS.transform({
        stylesheetText: xsltSheet,
        sourceText: serializer(inxml),
        destination: 'serialized'},
        'sync');
    const indoc = parseXML(processed.principalResult);

    transliterateTitle(indoc,inxml);

    const header = '<?xml version="1.0" encoding="UTF-8"?>';

    if(!outtext)
        fs.writeFile(outfile,header+serializer(indoc),{encoding: 'utf-8'},function(){return;});
    else {        
        const outdoc = parseXML(outtext);
        const newdoc = convertFile(indoc,outdoc);
        fs.writeFile(outfile,header+serializer(newdoc),{encoding: 'utf-8'},function(){return;});
    }
};

main();
