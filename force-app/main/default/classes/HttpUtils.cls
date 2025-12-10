/**
* @description       : 
* @author            : Aymen Jelassi
* @group             : 
* @last modified on  : 03-12-2025
* @last modified by  : REEJ_AJ
**/
public with sharing class HttpUtils {
    
    public static String buildHttpUrl(Map<String, Object> params){
        String url = '';   
        String url2='';
        String url3 = '';
        String url4 = '';
        for (String key : params.keySet()){
            if (url.length() != 0 && url.right(1)!='&'){
                url += '&';
            } 
            if (isMap(params.get(key)) && isMapString(params.get(key))){
                
                Map<String,String> mp = (Map<String,String>) params.get(key);
                System.debug(mp);
                if(mp!=null && !mp.isEmpty()){
                for (String keyn : mp.keySet()){
                    System.debug(keyn);
                    if (url2.length() != 0 ){
                        url2 += '&';
                    } 
                    url2 += key+'['+keyn+']'+'='+EncodingUtil.urlEncode((String) mp.get(keyn) != null ?(String) mp.get(keyn)  : '', 'UTF-8');
                }
            }
            }else if(isMap(params.get(key)) && !isMapArray(params.get(key))){
                Map<String,Object> mp2 = (Map<String,Object>) params.get(key);
                for (String keyn2 : mp2.keySet()){
                    if(isMap(mp2.get(keyn2)) && mp2.get(keyn2) != null){
                        Map<String,String> mp3 = (Map<String,String>) mp2.get(keyn2);
                        System.debug(mp2.get(keyn2));
                        for (String kk : mp3.keySet()){
                            if (url3.length()!= 0){
                                url3 += '&';
                            }
                            url3 += key+'['+keyn2+']'+'['+kk+']'+'='+EncodingUtil.urlEncode((String) mp3.get(kk) != null ? (String) mp3.get(kk) : '' , 'UTF-8');
                        }
                    }else{
                        if (url3.length()!= 0){
                            url3 += '&';
                        }
                        if((!isMap(mp2.get(keyn2)))&& !isList(mp2.get(keyn2))){
                            if (keyn2 == 'default_tax_rates[]'){
                                url3 += key+keyn2+'='+EncodingUtil.urlEncode((String) mp2.get(keyn2) != null ? (String) mp2.get(keyn2)  : '', 'UTF-8');
                            }else{
                                url3 += key+'['+keyn2+']'+'='+EncodingUtil.urlEncode((String) mp2.get(keyn2) != null ? (String) mp2.get(keyn2) : '', 'UTF-8');
                            }
                        }else{
                            System.debug(key);
                            System.debug(keyn2);
                            if (mp2.get(keyn2) != null){
                                List<Map<String,String>> mpch = (List<Map<String,String>>) mp2.get(keyn2);
                                for(integer i=0;i<mpch.size();i++){
                                    Map<String,String> sc = (Map<String,String>)mpch.get(i);
                                    for (String sc1 : sc.keySet()){
                                        url3+=key+keyn2+'['+i+']'+sc1+'='+ EncodingUtil.urlEncode((String) sc.get(sc1), 'UTF-8')+'&';
                                    }
                                }
                            } 
                           
                        }
                    }
                }
                
            }
            
            else if(isMapArray(params.get(key))&& params.get(key)!=null){
                List<Map<String,String>> mp4 = (List<Map<String,String>>) params.get(key);
                for (integer i=0;i<mp4.size();i++){
                    if (url4.length()!= 0){
                        url4 += '&';
                    }
                 //   url4 += key+'['+i+']';
                    for (String pk : mp4.get(i).keySet() ){
                        if (pk == 'quantity'||pk=='type'||pk=='unit_amount'||pk=='description'||pk=='tax_rates'){
                            url4+='&';
                        }
                        url4 += key+'['+i+']';
                        System.debug(mp4.get(i));
                        if(pk=='tax_rates'){
                            url4 += pk+'[]'+'='+EncodingUtil.urlEncode((String) mp4.get(i).get(pk), 'UTF-8')+'&';
                        }else{
                            url4 += '['+pk+']'+'='+EncodingUtil.urlEncode((String) mp4.get(i).get(pk), 'UTF-8')+'&';

                        }
                    }
                }
            }
            else{
                url += key + '=' + EncodingUtil.urlEncode((String) params.get(key), 'UTF-8');  
            }
            
            // url += key + '=' + params.get(key);            
        } 
        url+='&'+url2+'&'+url3+'&'+url4;
        url = url.replaceAll('&&&&', '&');
        url = url.replaceAll('&&&', '&');
        url = url.replaceAll('&&', '&');
        url = url.removeEnd('&');
        system.debug(url);
        return url;
    } 
    public static boolean isMap(Object input){
        try{
            Map<String,Object> tempmap = (Map<String,Object>)input;
            return true;
            
        }catch(Exception e){
            return false;
        } 
    } 
    
    public static boolean isMapString(Object input){
        try{
            Map<String,String> tempmap = (Map<String,String>)input;
            return true;
            
        }catch(Exception e){
            return false;
        }
    } 

    public static boolean isMapArray(Object input){
        try{
           List<Map<String,String>> tempmap = (List<Map<String,String>> )input;
            return true;
            
        }catch(Exception e){
            return false;
        }
    } 

    public static Boolean isList(Object input)
{
    Object test;
    try{
       test = (List<Object>)input;
       return true;
    }
    catch(System.TypeException ex){}
    return false;
}
    
}