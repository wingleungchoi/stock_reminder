require 'rubygems'
require 'mechanize'
require 'pry'

def remove_dividend_entries(trs) # input an array of trs (Nokogiri::XML::Element) and remove divident entries and return a new array of trs
  trs.each do |tr|
    trs.delete(tr) if /股利|股票/.match(tr.text.strip) #Both work
    #trs.delete(tr) if tr.children.length != 7
  end
  trs.each do |tr| # I repeat intentionly because of long reason, call me to explain,please refer to https://hk.finance.yahoo.com/q/hp?s=0133.HK&a=0&b=12&c=2000&d=0&e=25&f=2015&g=d&z=66&y=396
    trs.delete(tr) if /股利|股票/.match(tr.text.strip) #Both work
    #trs.delete(tr) if tr.children.length != 7
  end
  return trs
end

def remove_header_and_footer(trs) # input an array of trs (Nokogiri::XML::Element) and remove first and last element and return a new  array
  trs.shift
  trs.pop
  return trs
end

def download_table_rows_from_a_page(page) # input page (a object of Mechanize gem) and return an array of trs (Nokogiri::XML::Element) in one page
  parseable_page = page.parser
  table_rows_in_a_page = parseable_page.css("table#yfncsumtab").css("tr[valign='top']").css("table.yfnc_datamodoutline1").css("table[cellpadding='2']").css("tr")
  table_rows_in_a_page = table_rows_in_a_page.to_a # makes it acts like an array to facilitate following methods
  table_rows_in_a_page = remove_header_and_footer(table_rows_in_a_page) # remove first element 日期開市高低收市成交量調整後的收市價* and last element * 收市價已按股息和拆細而調整
  table_rows_in_a_page = remove_dividend_entries(table_rows_in_a_page)
end

def download_table_rows(stock_number)# input a string of 4 ditil and return an array of tr needed
  # assumption : yahoo default show data show from the day you search.
  url = "https://hk.finance.yahoo.com/q/hp?s=#{stock_number}.HK"
  agent = Mechanize.new
  page = agent.get(url)
  table_rows = []
  table_rows += download_table_rows_from_a_page(page)
  10.times do   # only 10 times to prevent database overload
    page = agent.page.link_with(:text => '下一頁').click 
    table_rows += download_table_rows_from_a_page(page)
  end 
  return table_rows 
end

def translate_chinese_y_m_d_to_universal(date_in_chinese)
  return date_in_chinese.gsub(/[年月]/, "-").gsub(/[日]/,'')
end

def translate_volume_to_integer(volume_string)
  return volume_string.gsub(/[,]/, "").to_i
end

def make_tr_to_data(trs) # input an array of trs (Nokogiri::XML::Element) to return a array of hash where {date: "2012-04-11"(class: date),open: "28.800"(class: float), high: "28.800"(class: float), low: "28.150"(class: float), close: "28.650"(class: float), trading_volume: "3,113,4000"(class: integer), adjusted_close: "26.540"(class: float)}}
  sanitized_data = []
  a = []
  trs.each_index do |index|
    sanitized_data[index] = {}
    standardized_date = translate_chinese_y_m_d_to_universal( trs[index].children[0].text)
    integerified_trading_volume = translate_volume_to_integer(trs[index].children[5].text)
    sanitized_data[index][:date] =  Date.parse standardized_date
    sanitized_data[index][:open] = trs[index].children[1].text.to_f
    sanitized_data[index][:high] = trs[index].children[2].text.to_f
    sanitized_data[index][:low] = trs[index].children[3].text.to_f
    sanitized_data[index][:close] = trs[index].children[4].text.to_f
    sanitized_data[index][:trading_volume] = integerified_trading_volume
    sanitized_data[index][:adjusted_close] = trs[index].children[6].text.to_f
  end
  return sanitized_data
end

def download_from_yahoo(stock_number) #input a string of 4 ditil and return an array of hashs where each hash is a daily price like {date: 2015-01-05, high: 140,...}
  trs = download_table_rows(stock_number) # input a string of 4 ditil and return an array of tr (Nokogiri::XML::Element) needed
  return make_tr_to_data(trs) # input an array of tr and returnreturn an array of hashs where each hash is a daily price.
end

NUMBER_OF_MISSING_STOCK = [49, 80, 134, 140, 150,153, 192, 203, 249, 284, 288, 301, 304, 314, 324, 325, 331, 344, 349, 394, 400, 401, 407, 409, 414, 415, 416, 424, 427, 429, 434, 436, 437, 441, 442, 443, 446, 447, 448, 452, 453, 454, 457, 461, 462, 463, 466, 470, 473, 478, 481, 484, 490, 492]
# error in english because website source are different 
# When under 11, EN stock name works find  checked by human =_=...WTX...
NAME_STOCKS_EN= ["CHEUNG KONG", "CLP HOLDINGS", "HK & CHINA GAS", "WHARF HOLDINGS", "HSBC HOLDINGS", "POWER ASSETS", "HOIFU ENERGY", "PCCW", "CHEUNG WO IHL", "HANG LUNG GROUP", "HANG SENG BANK", "HENDERSON LAND", "HUTCHISON", "HYSAN DEV", "VANTAGE INT'L", "SHK PPT", "NEW WORLD DEV", "ORIENTAL PRESS", "SWIRE PACIFIC A", "WHEELOCK", "GREAT CHI PPT", "MEXAN", "BANK OF E ASIA", "BURWILL", "CHEVALIER INT'L", "CHINA MOTOR BUS", "GALAXY ENT", "TIAN AN", "DYNAMIC HOLD", "ABC COM (HOLD)", "CHINA AEROSPACE", "CROSS-HAR(HOLD)", "HARMONIC STR", "KOWLOON DEV", "FE CONSORT INTL", "FE HLDGS INTL", "FE HOTELS", "FIRST TRACTOR", "SINO DISTILL", "GOLD PEAK", "GREAT EAGLE H", "NE ELECTRIC", "C.P. POKPHAND", "HAECO", "HK&S HOTELS", "COMPUTER & TECH", "HOP HING GROUP", "C AUTO INT DECO", "HK FERRY (HOLD)", "HARBOUR CENTRE", "FAIRWOOD HOLD", "GUOCO GROUP", "HOPEWELL HOLD", "NEWAY GROUP", "ALLIED PPT (HK)", "CHEN HSONG HOLD", "SUNWAY INT'L", "SKYFAME REALTY", "HK FOOD INV", "NORTH ASIA RES", "TRANSPORT INT'L", "WINFOONG INT'L", "GET NICE", "DETEAM CO LTD", "MTR CORPORATION", "LUMENA NEWMAT", "LEE HING", "SHANGRI-LA ASIA", "NEPTUNE GROUP", "MIRAMAR HOTEL", "MODERN MEDIA", "ASIAN CITRUS", "Y.T. REALTY", "SOUTH SEA PETRO", "AMS TRANSPORT", "REGAL INT'L", "CENTURY LEGEND", "CH OVS G OCEANS", "V1 GROUP", "SINO LAND", "STELUX HOLDINGS", "CHINA ELECTRON", "SUN HUNG KAI CO", "SWIRE PACIFIC B", "TAI CHEUNG HOLD", "TAI SANG LAND", "AMBER ENERGY", "INT'L STD RES", "CHAMPION TECH", "TERMBRAY IND", "GREENHEART GP", "LVGEM CHINA", "YUSEI", "HENDERSON INV", "XINGFA ALUM", "WONG'S INT'L", "CLEAR MEDIA", "HANG LUNG PPT", "SUMMIT ASCENT", "SHOUGANG CENT", "ASIA COMM HOLD", "ASSO INT HOTELS", "LANDSEA PPT", "SICHUAN EXPRESS", "GR PROPERTIES", "GOOD FELLOW RES", "CHINA FORTUNE", "CINDA INTL HLDG", "LT COMM REALEST", "DICKSON CONCEPT", "HERALD HOLD", "GRAND FIELD GP", "CHOW SANG SANG", "EYANG HOLDINGS", "COSMOS MACH", "POLY PROPERTY", "COSMOPOL INT'L", "C.P. LOTUS", "CROCODILE", "YUEXIU PROPERTY", "GD LAND", "SUN HING VISION", "CARRIANNA", "CHINESE EST H", "ENM HOLDINGS", "ASIA STANDARD", "MOISELLE INT'L", "CHEUK NANG HOLD", "CHINA INV HOLD", "KUNLUN ENERGY", "MASCOTTE HOLD", "JINHUI HOLDINGS", "CCT FORTIS", "CHINA JINHAI", "GREAT CHINA", "FIRST PACIFIC", "GLOBAL TECH", "CHINA MER HOLD", "HK BLDG & LOAN", "TAI PING CARPET", "CHAOYUE GROUP", "KINGBOARD CHEM", "CH AGRI-PROD EX", "WANT WANT CHINA", "SHENZHEN INT'L", "CHINA SAITE", "BEIJING DEV(HK)", "CHINA SOLAR", "LIPPO CHINA RES", "NATURAL BEAUTY", "MELBOURNE ENT", "BROCKMAN MINING", "HON KWOK LAND", "AVIC IHL", "CENTURY GINWA", "EMPEROR INT'L", "REXGLOBAL ENT", "CHINA EB LTD", "NEWTIMES ENERGY", "IDT INT'L", "TSINGTAO BREW", "WANDA HOTEL DEV", "SILVER GRANT", "GOLDBOND GROUP", "K. WAH INT'L", "GEMINI INV", "GEELY AUTO", "UNITED PACIFIC", "JIANGSU EXPRESS", "SA SA INT'L", "JOHNSON ELEC H", "KADER HOLDINGS", "FUJIAN HOLDINGS", "CHINA WINDPOWER", "RICHFIELD GP", "KECK SENG INV", "HENG FAI ENT", "GRANDE HOLDINGS", "JINGCHENG MAC", "SUNWAH KINGSWAY", "DONGYUE GROUP", "HKC (HOLDINGS)", "LAI SUN INT'L", "CAPITAL ESTATE", "LIU CHONG HING", "L'SEA RESOURCES", "HONGHUA GROUP", "HENG TAI", "SMI HOLDINGS", "ITC PROPERTIES", "MELCO INT'L DEV", "MAGNIFICENT", "EVERCHINA INT'L", "SEEC MEDIA", "TSC GROUP", "JOY CITY PPT", "POLYTEC ASSET", "CH TYCOON BEV", "DAPHNE INT'L", "STYLAND HOLD", "NANYANG HOLD", "NATIONAL ELEC H", "ASIA ORIENT", "HUTCHTEL HK", "CHINNEY INV", "CHINA CHENGTONG", "SHENYIN WANGUO", "SHUN HO TECH", "U-PRESID CHINA", "PNG RESOURCES", "MIN XIN HOLD", "SRGL", "PIONEER GLOBAL", "POKFULAM", "LIPPO", "FIRST SHANGHAI", "CHINA ENERGY", "RAYMOND IND", "MINMETALS LAND", "MADEX INTL HOLD", "AVIC INT'L", "MY MEDICARE", "NEW CENTURY GP", "CHINA STRATEGIC", "SAN MIGUEL HK", "SAFETY GODOWN", "EVERGREEN INT", "PAK FAH YEOW", "BUILD KING HOLD", "ALI HEALTH", "SHUN TAK HOLD", "QPL INT'L", "SINCERE", "CHINA SEVENSTAR", "REALGOLD MINING", "TST PROPERTIES", "HKC INT'L HOLD", "SINO-I TECH", "SEA HOLDINGS", "SE ASIA PPT", "SHUN HO RES", "NUR HOLDINGS", "LUNG KEE", "CITYCHAMP", "CHINA EB INT'L", "TOMSON GROUP", "YEEBO (INT'L H)", "AVIC JOY HLDG", "CCT LAND", "DESON DEV INT'L", "CH YUNNAN TIN", "CHANCO INT'L", "ORIENT VICTORY", "TIAN TECK LAND", "CITIC", "KINGDEE INT'L", "CRTG", "GUANGDONG INV", "DAN FORM HOLD", "SHUI ON LAND", "WILLIE INT'L", "C BILLION RES", "HANNY HOLDINGS", "MONGOLIA ENERGY", "TERN PROPERTIES", "WAH HA REALTY", "FREEMAN FIN", "KING FOOK HOLD", "RIVERA (HOLD)", "NEXT MEDIA", "GOLDIN PPT", "BYD ELECTRONIC", "CS HEALTH", "WINFAIR INV", "WH GROUP", "WING ON CO", "C FORTUNE FIN", "CHINA RESOURCES", "ASIA STD HOTEL", "CATHAY PAC AIR", "YANGTZEKIANG", "KONG SUN HOLD", "EMPEROR E HOTEL", "SINOFERT", "CHUANG'S CHINA", "SINOCOM SOFT", "KUNMING MACHINE", "VTECH HOLDINGS", "WULING MOTORS", "KWOON CHUNG BUS", "UP ENERGY DEV", "CHINA TRAVEL HK", "XH NEWS MEDIA", "LUEN THAI", "SHIRBLE STORE", "RICHLY FIELD", "SMARTONE TELE", "OOIL", "GUANGZHOU SHIP", "VONGROUP", "CHINA METAL", "COMPUTIME", "TEXWINCA HOLD", "TINGYI", "MAANSHAN IRON", "CHINA STAR ENT", "PAX GLOBAL", "ALCO HOLDINGS", "DRAGONITE INT'L", "ESPRIT HOLDINGS", "YUANHENG GAS", "TOP FORM INT'L", "PROVIEW INT'L", "UPBEST GROUP", "HUABAO INTL", "GREENLAND HK", "SHANGHAI PECHEM", "CHINA MINING", "CAFE DE CORAL H", "NEWOCEAN ENERGY", "CULTURECOM HOLD", "VITASOY INT'L", "YANCHANG PETRO", "ANGANG STEEL", "LUNG CHEONG", "JINGWEI TEXTILE", "ASIA ENERGY LOG", "FORTUNE SUN", "ENERGY INTINV", "CHINASOFT INT'L", "CENTURY C INT'L", "MEILAN AIRPORT", "JIANGXI COPPER", "HAISHENG JUICE", "NEW FOCUS AUTO", "SINO GOLF HOLD", "C ZENITH CHEM", "SHANGHAI IND H", "PING SHAN TEA", "SUN EAST TECH", "LUKS GROUP (VN)", "CHUANG'S INT'L", "SINOTRANS SHIP", "WING TAI PPT", "CHINA BEST", "BJ ENT WATER", "ITC CORPORATION", "ALLIED GROUP", "FOUR SEAS MER", "YGM TRADING", "REORIENT GROUP", "HUAJUN HOLD", "CIAM GROUP", "PME", "CHINA PIPE", "KIU HUNG ENERGY", "WELLING HOLDING", "COL CAPITAL", "CHINA GAS HOLD", "CHINNEY ALLI", "SINOPEC CORP", "LEEPORT(HOLD)", "HKEX", "TONTINE WINES", "CHINA RAILWAY", "MEI AH ENTER", "BEIJING ENT", "GLORIOUS SUN", "SMARTAC GP CH", "HING LEE (HK)", "JUNYANG SOLAR", "ORIENTAL WATCH", "UNITED GENE GP", "COGOBUY", "WANJIA GROUP", "PEACEMAP HOLD", "STARLITE HOLD", "HSIN CHONG CONS", "YAU LEE HOLD", "YIP'S CHEMICAL", "SOHO CHINA", "LAM SOON (HK)", "HERITAGE INT'L", "SOUTH CHINA CHI", "TSE SUI LUEN", "FOUNDER HOLD", "JIUHAO HEALTH", "FOUNTAIN SET", "VMEP HOLDINGS", "HKET HOLDINGS", "MINTH GROUP", "ONE MEDIA GROUP", "ORIENTAL EXPL", "G CHINA HOLD", "PCPD", "NORTH MINING", "BOYAA", "IRICO", "KUANGCHI", "DAH SING", "SINCEREWATCH HK", "CHINA FIRE", "CHIGO HOLDING", "HUNG HING PRINT", "GCL NEWENERGY", "TIANDA PHARMA", "NEW CITY DEV", "TRISTATE HOLD", "MIDLAND IC&I", "SIHUAN PHARM", "NATURAL DAIRY", "KENFORD GROUP", "FUTONG TECH", "UNITEDENERGY GP", "GAPACK", "CAPXON INT'L", "CMMB VISION", "JLF INVESTMENT", "HAO TIAN DEV", "ZHONG FA ZHAN", "CH DYNAMICS", "AUPU GROUP HLDG", "CIL HOLDINGS", "HKR INT'L", "SANDMARTIN INTL", "BAUHAUS INT'L", "FORGAME", "SHIHUA DEV", "RUSAL", "SUCCESSUNIVERSE", "LAI SUN DEV", "DONGFENG GROUP", "SEE CORPORATION", "GOME", "LI & FUNG", "PALADIN", "KASEN", "CSI PROPERTIES", "PYI CORP", "QINGDAO HLDGS", "FRONTIER SER"]
NAME_STOCKS_ZH =["長江實業", "中電控股", "香港中華煤氣", "九龍倉集團", "匯豐控股", "電能實業", "凱富能源", "電訊盈科", "長和國際實業", "恆隆集團", "恆生銀行", "恆基地產", "和記黃埔", "希慎興業", "盈信控股", "新鴻基地產", "新世界發展", "東方報業集團", "太古股份公司Α", "會德豐", "大中華地產控股", "茂盛控股", "東亞銀行", "寶威控股", "其士國際", "中華汽車", "銀河娛樂", "天安", "達力集團", "佳訊控股", "航天控股", "港通控股", "和協海峽金融集團", "九龍建業", "遠東發展", "遠東控股國際", "遠東酒店實業", "第一拖拉機股份", "中國釀酒集團", "金山工業", "鷹君", "東北電氣", "卜蜂國際", "香港飛機工程", "大酒店", "科聯系統", "合興集團", "中國汽車內飾", "香港小輪（集團）", "海港企業", "大快活集團", "國浩集團", "合和實業", "中星集團控股", "聯合地產（香港）", "震雄集團", "新威國際", "天譽置業", "香港食品投資", "北亞資源", "載通", "榮豐國際", "結好控股", "弘海有限公司", "港鐵公司", "旭光高新材料", "利興發展", "香格里拉（亞洲）", "海王集團", "美麗華酒店", "現代傳播", "亞洲果業", "長城科技股份", "渝太地產", "南海石油", "進智公共交通", "富豪國際", "世紀建業", "中國海外宏洋集團", "第一視頻", "信和置業", "寶光實業", "中國電子", "新鴻基公司", "太古股份公司Β", "大昌集團", "大生地產", "琥珀能源", "標準資源控股", "冠軍科技", "添利工業", "綠森集團", "綠景中國地產", "YUSEI", "恆基發展", "興發鋁業", "王氏國際", "白馬戶外媒體", "恆隆地產", "凱升控股", "首長寶佳", "ASIACOMMOLD", "凱聯國際酒店", "朗詩綠色地產", "四川成渝高速公路", "國銳地產", "金威資源", "中國長遠", "信達國際控股", "勒泰商業地產", "迪生創建", "興利集團", "鈞濠集團", "周生生", "宇陽控股", "大同機械", "保利置業集團", "COSMOPOLINT'L", "卜蜂蓮花", "鱷魚恤", "越秀地產", "粵海置地", "新興光學", "佳寧娜", "華人置業", "安寧控股", "泛海集團", "慕詩國際", "卓能（集團）", "中國興業控股", "招商局中國基金", "昆侖能源", "馬斯葛集團", "金輝集團", "中建富通", "中國金海國際", "大中華集團", "第一太平", "耀科國際", "招商局國際", "香港建屋貸款", "太平地氈", "超越集團", "建滔化工", "中國農產品交易", "中國旺旺", "深圳國際", "北京發展（香港）", "中國源暢", "力寶華潤", "自然美", "萬邦投資", "布萊克萬礦業", "漢國置業", "中航國際控股", "世紀金花", "英皇國際", "御濠娛樂", "中國光大控股", "新時代能源", "萬威國際", "青島啤酒股份", "萬達酒店發展", "中國資本", "銀建國際", "金榜集團", "嘉華國際", "盛洋投資", "吉利汽車", "聯太工業", "江蘇寧滬高速公路", "莎莎國際", "德昌電機控股", "開達集團", "閩港控股", "中國風電", "田生集團", "激成投資", "恆輝企業控股", "嘉域集團", "京城機電股份", "新華匯富金融", "東岳集團", "香港建設（控股）", "麗新國際", "冠中地產", "廖創興企業", "利海資源", "宏華集團", "亨泰", "星美控股", "德祥地產", "新濠國際發展", "華大地產", "潤中國際控股", "中國投資開發—新", "財訊傳媒", "ＴＳＣ集團", "大悅城地產", "保利達資產", "中國大亨飲品", "達芙妮國際", "大凌集團", "南洋集團", "樂聲電子", "匯漢控股", "和記電訊香港", "建業實業", "中國誠通發展集團", "申銀萬國", "順豪科技", "統一企業中國", "ＰＮＧ資源", "閩信集團", "神州資源", "建生國際", "博富臨置業", "力寶", "第一上海", "中能控股", "利民實業", "五礦建設", "盛明國際控股", "中國航空工業國際", "銘源醫療", "新世紀集團", "中策集團", "香港生力啤", "安全貨倉", "長興國際", "白花油", "利基控股", "阿里健康", "信德集團", "品質國際", "先施", "中國七星控股", "瑞金礦業", "尖沙咀置業", "香港通訊國際控股", "中國數碼信息", "爪哇控股", "華信地產財務", "順豪資源集團", "國家聯合資源", "龍記集團", "冠城鐘錶珠寶", "中國光大國際", "湯臣集團", "億都（國際控股）", "幸福控股", "中建置地", "迪臣發展國際", "中國雲錫礦業", "卓高國際", "東勝中國", "天德地產", "中信股份", "金蝶國際", "中國資源交通", "粵海投資", "丹楓控股", "瑞安房地產", "威利國際", "中富資源", "錦興集團", "蒙古能源", "太興置業", "華廈置業", "民豐企業", "景福集團", "川河集團", "壹傳媒", "高銀地產", "比亞迪電子", "同佳健康", "永發置業", "永安國際", "中國富強金融", "華潤創業", "泛海酒店", "國泰航空", "長江製衣", "江山控股", "英皇娛樂酒店", "中化化肥", "莊士中國", "中訊軟件", "昆明機床", "永亨銀行", "VTECOLDINGS", "五菱汽車", "冠忠巴士集團", "優派能源發展", "香港中旅", "新華通訊頻媒", "嘉進投資國際", "聯泰控股", "歲寶百貨", "裕田中國", "數碼通電訊", "東方海外國際", "廣州廣船國際股份", "黃河實業", "勤美達國際", "金寶通", "德永佳集團", "康師傅控股", "馬鞍山鋼鐵股份", "中國星集團", "百富環球", "愛高集團", "三龍國際", "思捷環球", "元亨燃氣", "黛麗斯國際", "唯冠國際", "美建集團", "華寶國際", "綠地香港", "上海石油化工股份", "安利時投資", "中國礦業", "大家樂集團", "新海能源", "文化傳信", "維他奶國際", "延長石油國際", "鞍鋼股份", "龍昌", "經緯紡織機械股份", "亞洲能源物流", "富陽", "能源國際投資", "中國軟件國際", "世紀城市國際", "鼎立資本", "美蘭機場", "江西銅業股份", "海升果汁", "新焦點", "順龍控股", "中國天化工", "上海實業控股", "坪山茶業", "日東科技", "陸氏集團（越南）", "莊士機構國際", "中外運航運", "永泰地產", "國華", "北控水務集團", "德祥企業", "聯合集團", "四洲集團", "ＹＧＭ貿易", "瑞東集團", "華君控股", "事安集團", "必美宜", "中國管業", "僑雄能源", "威靈控股", "中國網絡資本", "中國燃氣", "建聯集團", "中國石油化工股份", "力豐（集團）", "香港交易所", "通天酒業", "中國中鐵", "美亞娛樂資訊", "北京控股", "旭日企業", "中國智能集團", "興利（香港）控股", "君陽太陽能", "東方表行集團", "聯合基因集團", "天下圖控股", "星光集團", "新昌營造", "越秀房產信託基金", "有利集團", "葉氏化工集團", "ＳＯＨＯ中國", "南順（香港）", "漢基控股", "南華中國", "謝瑞麟", "方正控股", "中國９號健康", "福田實業", "中國大冶優先股", "越南製造加工出口", "經濟日報集團", "敏實集團", "萬華媒體", "亨亞", "東方網庫", "大中華實業", "盈大地產", "北方礦業", "陽光房地產基金", "彩虹電子", "光啟科學", "大新金融", "SINCEREWATC", "中國消防", "志高控股", "鴻興印刷集團", "協鑫新能源", "天大藥業", "新城市建設發展", "聯亞集團", "美聯工商舖", "四環醫藥", "建福集團", "富通科技", "聯合能源集團", "紛美包裝", "凱普松國際", "中播控股", "金六福投資", "昊天發展集團", "中發展控股", "中國動力控股", "奧普集團控股", "華建控股", "香港興業國際", "聖馬丁國際", "包浩斯國際", "實華發展", "RUSAL", "實德環球", "麗新發展", "東風集團股份", "漢傳媒", "國美電器", "利豐", "百利大", "卡森國際", "資本策略地產", "保華集團", "青島控股", "先豐服務集團"]

def grab_close_prices(days, sanitized_data, day_index) # input days (integer), sanitized_data (array of hashs), day_index(ingeter) and return a array of close_prices (integer)
  close_prices = sanitized_data.map{ |daily_price| daily_price[:close] }.take(days + day_index)  
  day_index.times do
    close_prices.shift
  end
  close_prices
end

def get_moving_avg(days,close_prices) # input an array of 250 integers and return a integer
  close_prices.inject{|sum, n| sum + n}/days.to_f
end

def moving_average(days, sanitized_data, day_index)
  close_prices = grab_close_prices(days, sanitized_data, day_index)
  get_moving_avg(days, close_prices).round(3)
end

(0..9).to_a.each do |index|  # create instances of the table Stock
  if !NUMBER_OF_MISSING_STOCK.include?(index+1)
    Stock.create(stock_number: (index + 1), name: NAME_STOCKS_EN.shift )
  end
end


(0..9).to_a.each do |stock_number_i| # create instances of the table Dailyprice
  stock_number = ''
  case stock_number_i
  when 0..8
  stock_number = "000" + (stock_number_i + 1).to_s    
  when 9..98
  stock_number = "00" + (stock_number_i + 1).to_s  
  when 99..499
  stock_number = "0" + (stock_number_i + 1).to_s      
  end
  if !NUMBER_OF_MISSING_STOCK.include?(stock_number_i + 1)
    data = download_from_yahoo(stock_number)
    total_index_of_data = data.length - 1
    (0..total_index_of_data).each do |data_i|
      daily_price = DailyPrice.new
      daily_price.stock_number = stock_number_i + 1
      daily_price.date = data[data_i][:date]
      daily_price.open = data[data_i][:open].to_f
      daily_price.high = data[data_i][:high].to_f
      daily_price.low = data[data_i][:low].to_f
      daily_price.close = data[data_i][:close].to_f
      daily_price.trading_volume = data[data_i][:trading_volume].to_i
      daily_price.adjusted_close = data[data_i][:adjusted_close].to_f
      daily_price.moving_250 = moving_average(250, data, data_i) if data.length - data_i > 250
      daily_price.moving_25 = moving_average(23, data, data_i)  if data.length - data_i > 25
      daily_price.save
    end
  end
end
