from lxml.html import fromstring
from requests import get
from re import findall,sub
import pandas as pd
from functools import reduce

def get_bp_html():
    url = "https://backpack.tf/spreadsheet"
    response = get(url)
    return fromstring(response.text)

def get_table():
    htmldoc = get_bp_html()
    trs = htmldoc.findall(".//tr")
    data = [[
            td.text_content().split('\n')[0]
            if len(td.attrib) == 0 
            else td.get('abbr') 
            for td in tr.findall('.//td')]
        for tr in trs[1:]]
    ths = trs[0].findall('.//th')
    headers = [sub(r"\s*","",th.text_content()) for th in ths]
    return data,headers
    
def get_frame():
    data,headers = get_table()
    return pd.DataFrame(data,columns=headers)

def get_faceit_items():
    f = open("tf2.html")
    htmldoc = fromstring(f.read())
    table_items = htmldoc.find_class("shop-page__item-list")[0]
    return [{"Price":li.find_class("item-card__price")[0].text_content(),
            "Name":sub(r"The |Strange ","",sub(r"\n\s*","",li.find_class("item-card__description")[0].text_content())).upper(),
            "IsStrange":"Strange" in li.find_class("item-card__description")[0].text_content()}
            for li in table_items.findall(".//li")]
            
def compare_data():
    df = get_frame()
    df["Name"] = df["Name"].apply(str.upper)
    faceit = get_faceit_items()
    finalitems = reduce(lambda x,y: x.append(y),[df[["Name","Unique","Strange"]][df["Name"] == x["Name"].upper()] for x in faceit])
    finaltable = finalitems.merge(pd.DataFrame(faceit),on="Name")
    finaltable["Price"] = finaltable["Price"].replace(',','',regex=True).astype(int)
    finaltable["Unique"] = finaltable["Unique"].astype(float)
    finaltable["Strange"] = finaltable["Strange"].astype(float)
    uniques = finaltable["Price"].divide(finaltable["Unique"]).multiply(~finaltable["IsStrange"]).fillna(0)
    stranges = finaltable["Price"].divide(finaltable["Strange"]).multiply(finaltable["IsStrange"]).fillna(0)
    finaltable["Diff"] = uniques+stranges
    return finaltable[["Name","Price","Diff","Unique","Strange"]].sort_values(by="Diff")
    
if __name__ == "__main__":
	print(compare_data())