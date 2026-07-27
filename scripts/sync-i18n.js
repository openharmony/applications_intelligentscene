/**
 * Sync i18n resources for zh_CN, zh_TW, en_GB, ug, bo_CN
 */
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const REF = path.resolve(ROOT, '..', 'intelligent-scene');
const TARGET_LANGS = ['zh_CN', 'zh_TW', 'en_GB', 'ug', 'bo_CN'];

const MODULES = [
  { rel: 'AppScope/resources', ref: true },
  { rel: 'common/src/main/resources', ref: false },
  { rel: 'product/phone/src/main/resources', ref: true },
  { rel: 'feature/configlinkage/src/main/resources', ref: false },
  { rel: 'feature/configmanage/src/main/resources', ref: false },
  { rel: 'feature/modeconfig/src/main/resources', ref: false },
  { rel: 'feature/notdisturb/src/main/resources', ref: true },
];

// Build s2t char map from common zh_CN vs zh_TW
function buildS2TMap() {
  const map = {};
  const pairs = [
    ['common/src/main/resources/zh_CN/element/string.json', 'common/src/main/resources/zh_TW/element/string.json'],
    ['product/phone/src/main/resources/zh_CN/element/string.json', path.join(REF, 'product/phone/src/main/resources/zh_TW/element/string.json')],
  ];
  for (const [cnPath, twPath] of pairs) {
    const cnFull = path.isAbsolute(cnPath) ? cnPath : path.join(ROOT, cnPath);
    const twFull = twPath.includes(':') || twPath.startsWith('/') ? twPath : path.join(ROOT, twPath);
    if (!fs.existsSync(cnFull) || !fs.existsSync(twFull)) {
      continue;
    }
    const cn = readStrings(cnFull);
    const tw = readStrings(twFull);
    for (const [name, cnItem] of cn) {
      const twItem = tw.get(name);
      if (!twItem) {
        continue;
      }
      const a = cnItem.value;
      const b = twItem.value;
      if (a.length !== b.length) {
        continue;
      }
      for (let i = 0; i < a.length; i++) {
        if (a[i] !== b[i]) {
          map[a[i]] = b[i];
        }
      }
    }
  }
  // Common simplified -> traditional chars
  const extra = '开关设置确认删除访问读取允许前往知道了完成取消选择应用模式情景学习睡眠勿扰驾驶运动游戏娱乐工作极限续航闹钟定时重复每周一二三四五六日分钟小时明天昨天今天开启关闭添加编辑保存返回确定提示权限位置日历联系人电话短信通知蓝牙网络壁纸云空间升级业务立即体验户外探索轨迹记录紧急卫星天气';
  const extraT = '開關設置確認刪除訪問讀取允許前往知道了完成取消選擇應用模式情景學習睡眠勿擾駕駛運動遊戲娛樂工作極限續航鬧鐘定時重複每週一二三四五六日分鐘小時明天昨天今天開啟關閉添加編輯保存返回確定提示權限位置日曆聯繫人電話短信通知藍牙網絡壁紙雲空間升級業務立即體驗戶外探索軌跡記錄緊急衛星天氣';
  for (let i = 0; i < extra.length; i++) {
    if (extra[i] !== extraT[i]) {
      map[extra[i]] = extraT[i];
    }
  }
  return map;
}

const S2T_MAP = buildS2TMap();

function s2t(text) {
  return [...text].map((c) => S2T_MAP[c] || c).join('');
}

function readStrings(filePath) {
  if (!fs.existsSync(filePath)) {
    return new Map();
  }
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  const map = new Map();
  for (const item of data.string || []) {
    map.set(item.name, { ...item });
  }
  return map;
}

function readPlurals(filePath) {
  if (!fs.existsSync(filePath)) {
    return null;
  }
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function collectRefStrings(lang) {
  const map = new Map();
  const dirs = [
    path.join(REF, 'AppScope/resources'),
    path.join(REF, 'common/src/main/resources'),
    path.join(REF, 'product/phone/src/main/resources'),
    path.join(REF, 'feature/notdisturb/src/main/resources'),
  ];
  for (const dir of dirs) {
    const file = path.join(dir, lang, 'element/string.json');
    const items = readStrings(file);
    for (const [k, v] of items) {
      if (!map.has(k)) {
        map.set(k, v);
      }
    }
  }
  return map;
}

function collectAllRefByLang() {
  const result = {};
  for (const lang of TARGET_LANGS) {
    result[lang] = collectRefStrings(lang);
  }
  return result;
}

const REF_BY_LANG = collectAllRefByLang();

function resolveValue(name, baseItem, lang, moduleBase, zhCnItem, enGbItem) {
  const ref = REF_BY_LANG[lang].get(name);
  if (ref && ref.value) {
    return { ...baseItem, value: ref.value, attr: ref.attr || baseItem.attr };
  }
  const existing = moduleBase.get(name);
  if (existing && lang === 'zh_CN' && existing.value) {
    return { ...baseItem, value: existing.value, attr: existing.attr || baseItem.attr };
  }
  if (existing && lang === 'en_GB' && existing.value) {
    return { ...baseItem, value: existing.value, attr: existing.attr || baseItem.attr };
  }
  if (lang === 'zh_TW' && zhCnItem?.value) {
    return { ...baseItem, value: s2t(zhCnItem.value), attr: { priority: 'translate' } };
  }
  if ((lang === 'ug' || lang === 'bo_CN') && enGbItem?.value) {
    return { ...baseItem, value: enGbItem.value, attr: baseItem.attr };
  }
  if (lang === 'zh_CN' && baseItem.value) {
    return { ...baseItem, attr: baseItem.attr };
  }
  return { ...baseItem };
}

function writeJson(filePath, obj) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(obj, null, 4) + '\n', 'utf8');
}

function syncModule(mod) {
  const resDir = path.join(ROOT, mod.rel);
  const basePath = path.join(resDir, 'base/element/string.json');
  if (!fs.existsSync(basePath)) {
    console.log('SKIP (no base):', mod.rel);
    return;
  }
  const base = readStrings(basePath);
  const zhCnExisting = readStrings(path.join(resDir, 'zh_CN/element/string.json'));
  const enGbExisting = readStrings(path.join(resDir, 'en_GB/element/string.json'));

  for (const lang of TARGET_LANGS) {
    const existingLang = readStrings(path.join(resDir, lang, 'element/string.json'));
    const out = [];
    for (const [name, baseItem] of base) {
      if (existingLang.has(name) && (lang === 'zh_CN' || lang === 'en_GB')) {
        out.push(existingLang.get(name));
        continue;
      }
      const zhCn = zhCnExisting.get(name) || REF_BY_LANG.zh_CN.get(name);
      const enGb = enGbExisting.get(name) || REF_BY_LANG.en_GB.get(name) || baseItem;
      out.push(resolveValue(name, baseItem, lang, new Map(), zhCn, enGb));
    }
    writeJson(path.join(resDir, lang, 'element/string.json'), { string: out });
    console.log(`OK ${mod.rel} [${lang}] ${out.length} keys`);
  }

  const basePlural = readPlurals(path.join(resDir, 'base/element/plural.json'));
  if (basePlural) {
    for (const lang of TARGET_LANGS) {
      const pluralPath = path.join(resDir, lang, 'element/plural.json');
      if ((lang === 'zh_CN' || lang === 'en_GB') && fs.existsSync(pluralPath)) {
        continue;
      }
      const zhPlural = readPlurals(path.join(resDir, 'zh_CN/element/plural.json'));
      const enPlural = readPlurals(path.join(resDir, 'en_GB/element/plural.json')) || basePlural;
      let outPlural;
      if (lang === 'zh_TW' && zhPlural) {
        outPlural = {
          plural: zhPlural.plural.map((p) => ({
            ...p,
            value: p.value.map((v) => ({ ...v, value: s2t(v.value) })),
          })),
        };
      } else if (lang === 'ug' || lang === 'bo_CN') {
        outPlural = enPlural;
      } else if (lang === 'zh_CN' && zhPlural) {
        outPlural = zhPlural;
      } else {
        outPlural = enPlural;
      }
      writeJson(pluralPath, outPlural);
      console.log(`OK ${mod.rel} [${lang}] plural`);
    }
  }
}

console.log('S2T map size:', Object.keys(S2T_MAP).length);
for (const mod of MODULES) {
  syncModule(mod);
}
console.log('Done.');
