import fs from 'node:fs/promises';
import {FileBlob, SpreadsheetFile} from '@oai/artifact-tool';

const qa = 'D:/AI/Codex_Obsidian/10_Projects 项目/Roblox/00旅行伙伴/.qa/autonomy-start-20261013';
const target = 'F:/HunyueRoblox/TravelBuddy/design/config/workbooks/TravelConfig.xlsx';
const mode = process.argv[2] ?? 'preview';
const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(mode === 'verify' ? target : `${qa}/TravelConfig.before.xlsx`));
const sheet = workbook.worksheets.getItem('TravelSettings');
console.log((await workbook.inspect({kind:'sheet',include:'id,name',maxChars:3000})).ndjson);
console.log((await workbook.inspect({kind:'table',range:'TravelSettings!A1:C25',include:'values,formulas',tableMaxRows:25,tableMaxCols:3,maxChars:7000})).ndjson);
const before = await workbook.render({sheetName:'TravelSettings',range:'A1:C25',scale:2,format:'png'});
await fs.writeFile(`${qa}/settings-before.png`,new Uint8Array(await before.arrayBuffer()));

if (mode === 'verify') {
  const finalView = await workbook.render({sheetName:'TravelSettings',range:'A1:C12',scale:2,format:'png'});
  await fs.writeFile(`${qa}/settings-final-header-rest.png`,new Uint8Array(await finalView.arrayBuffer()));
}

if (mode === 'edit') {
  const additions = [
    ['PrepareMinSeconds',60,'正式服普通出发准备下限，秒。'],
    ['PrepareMaxSeconds',180,'正式服普通出发准备上限，秒。'],
    ['FirstPrepareSeconds',30,'首航准备固定30秒，Studio与正式服均不乘时间缩放。'],
    ['StudioPrepareMinSeconds',15,'Studio普通出发准备下限，直接使用秒数。'],
    ['StudioPrepareMaxSeconds',30,'Studio普通出发准备上限，直接使用秒数。'],
    ['SeaChoiceWeight_shallow',1,'Demo海域选择可调整默认，浅滩与近海当前等权，非最终平衡值。'],
    ['SeaChoiceWeight_near',1,'Demo海域选择可调整默认，仅船等级解锁后参与，非最终平衡值。'],
    ['ShortChoiceWeight',1,'Demo短长航程可调整默认，当前等权，非最终平衡值。'],
    ['LongChoiceWeight',1,'Demo短长航程可调整默认，当前等权，非最终平衡值。'],
  ];
  const rows = sheet.getRange('A4:C25').values;
  const restIndex = rows.findIndex(row=>row[0]==='RestSeconds');
  if(restIndex<0) throw new Error('RestSeconds missing');
  sheet.getRange(`B${restIndex+4}:C${restIndex+4}`).values = [[180,'归家休息正式180秒，沿用已有StudioTimeScale。']];
  for(let index=0;index<additions.length;index++) {
    const row = 26+index;
    sheet.getRange(`A${row}:C${row}`).copyFrom(sheet.getRange('A25:C25'),'all');
    sheet.getRange(`A${row}:C${row}`).values = [additions[index]];
  }
  // Only the edited settings view needs enough width for stable keys and notes.
  sheet.getRange('A1:A34').format.columnWidth = 33;
  sheet.getRange('B1:B34').format.columnWidth = 25;
  sheet.getRange('C1:C34').format.columnWidth = 90;
  workbook.recalculate();
  console.log((await workbook.inspect({kind:'table',range:'TravelSettings!A26:C34',include:'values,formulas',tableMaxRows:9,tableMaxCols:3,maxChars:6000})).ndjson);
  console.log((await workbook.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:300},summary:'final formula error scan',maxChars:2000})).ndjson);
  const after = await workbook.render({sheetName:'TravelSettings',range:'A24:C34',scale:2,format:'png'});
  await fs.writeFile(`${qa}/settings-after.png`,new Uint8Array(await after.arrayBuffer()));
  await (await SpreadsheetFile.exportXlsx(workbook)).save(target);
  console.log(`TRAVEL_SETTINGS_SAVED ${target}`);
}
