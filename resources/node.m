node() ;;2013-02-01  5:55 PM
 ;
 ; Written by David Wicksell <dlw@linux.com>
 ; Copyright © 2012,2013 Fourth Watch Software, LC
 ; 
 ; This program is free software: you can redistribute it and/or modify
 ; it under the terms of the GNU Affero General Public License (AGPL)
 ; as published by the Free Software Foundation, either version 3 of
 ; the License, or (at your option) any later version.
 ; 
 ; This program is distributed in the hope that it will be useful,
 ; but WITHOUT ANY WARRANTY; without even the implied warranty of
 ; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 ; GNU Affero General Public License for more details.
 ;
 ; You should have received a copy of the GNU Affero General Public License
 ; along with this program. If not, see http://www.gnu.org/licenses/.
 ;
 ;
 quit:$q "Call an API entry point" w "Call an API entry point" quit
 ;
 ;
parse(subs) ;parse an argument list or list of subscripts
 n $et s $et="zg "_$zl_":error^node"
 ;
 n i,num,sub,temp,tmp
 ;
 s (temp,tmp)=""
 ;
 i '$d(subs)#10 s subs=""
 i subs'="" d
 . f  q:subs=""  d
 . . s num=+subs,$e(subs,1,$l(num)+1)=""
 . . s sub=$e(subs,1,num)
 . . i sub["""" d
 . . . f i=1:1:$l(sub) d
 . . . . i $e(sub,i)="""" s tmp=tmp_""""_$e(sub,i)
 . . . . e  s tmp=tmp_$e(sub,i)
 . . . ;
 . . . s sub=tmp
 . . i (sub'=+sub&($e(sub,1,2)'="0."))!($e(sub)=".") s sub=""""_sub_""""_","
 . . e  s sub=sub_","
 . . ;
 . . s temp=temp_sub,$e(subs,1,num+1)=""
 s subs=temp
 s subs=$e(subs,1,$l(subs)-1)
 ;
 quit subs
 ;
 ;
construct(glvn,subs) ;construct a global reference
 n $et s $et="zg "_$zl_":error^node"
 ;
 n globalname,subscripts
 ;
 s subscripts=$$parse(.subs)
 s globalname="^"_glvn_$s(subscripts'="":"("_subscripts_")",1:"")
 ;
 quit globalname
 ;
 ;
escape(data) ;escape quotes or ctrl chars within a string in mumps
 n $et s $et="zg "_$zl_":error^node"
 ;
 n i,charh,charl,ndata
 ;
 s ndata=""
 f i=1:1:$l(data) d
 . i $e(data,i)="""" s ndata=ndata_"\"_$e(data,i)
 . e  i $e(data,i)="\" s ndata=ndata_"\"_$e(data,i)
 . e  i $e(data,i)?1c d
 . . s charh=$a($e(data,i))\16,charh=$e("0123456789abcdef",charh+1)
 . . s charl=$a($e(data,i))#16,charl=$e("0123456789abcdef",charl+1)
 . . s ndata=ndata_"\u00"_charh_charl
 . e  s ndata=ndata_$e(data,i)
 ;
 quit ndata
 ;
 ;
version() ;return the version string
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit "Node.js Adaptor for GT.M: Version: 0.1.2 (FWSLC); "_$zv
 ;
 ;
set(glvn,subs,data) ;set a global
 n $et s $et="zg "_$zl_":error^node"
 ;
 n globalname,ok,result,return
 ;
 s globalname=$$construct(glvn,.subs)
 s @globalname=data
 s ok=1,result=0
 ;
 s return="{""ok"": "_ok_", ""global"": """_glvn_""","
 s return=return_" ""result"": "_result_"}"
 ;
 quit return
 ;
 ;
get(glvn,subs) ;get one node of a global
 n $et s $et="zg "_$zl_":error^node"
 ;
 n data,defined,globalname,ok,return
 ;
 s globalname=$$construct(glvn,.subs)
 s data=$g(@globalname)
 s:data[""""!(data["'")!(data?.e1c.e) data=$$escape(data)
 ;
 i data'=+data s data=""""_data_""""
 ;
 s defined=$d(@globalname)#10
 s ok=1
 ;
 s return="{""ok"": "_ok_", ""global"": """_glvn_""","
 s return=return_" ""data"": "_data_", ""defined"": "_defined_"}"
 ;
 quit return
 ;
 ;
kill(glvn,subs) ;kill a global or global node
 n $et s $et="zg "_$zl_":error^node"
 ;
 n globalname,ok,result,return
 ;
 s globalname=$$construct(glvn,.subs)
 k @globalname
 ;
 s ok=1,result=0
 ;
 s return="{""ok"": "_ok_", ""global"": """_glvn_""","
 s return=return_" ""result"": "_result_"}"
 ;
 quit return
 ;
 ;
data(glvn,subs) ;find out if global node has data or children
 n $et s $et="zg "_$zl_":error^node"
 ;
 n globalname,defined,ok,return
 ;
 s globalname=$$construct(glvn,.subs)
 s defined=$d(@globalname)
 s ok=1
 ;
 s return="{""ok"": "_ok_", ""global"": """_glvn_""","
 s return=return_" ""defined"": "_defined_"}"
 ;
 quit return
 ;
 ;
order(glvn,subs,order) ;return the next global node at the same level
 n $et s $et="zg "_$zl_":error^node"
 ;
 n globalname,defined,ok,result,return
 ;
 s globalname=$$construct(glvn,.subs)
 ;
 i $g(order)=-1 s result=$o(@globalname,-1)
 e  s result=$o(@globalname)
 ;
 i $e(result)="^" s result=$e(result,2,$l(result))
 s:result[""""!(result["'")!(result?.e1c.e) result=$$escape(result)
 ;
 i subs,$e(result)="^" s $e(result)=""
 i (result'=+result&($e(result,1,2)'="0."))!($e(result)=".") s result=""""_result_""""
 ;
 s ok=1
 ;
 s return="{""ok"": "_ok_", ""global"": """_glvn_""","
 s return=return_" ""result"": "_result_"}"
 ;
 quit return
 ;
 ;
previous(glvn,subs) ;same as order, only in reverse
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit $$order(glvn,subs,-1)
 ;
 ;
nextNode(glvn,subs) ;
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit ""
 ;
 ;
previousNode(glvn,subs) ;
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit ""
 ;
 ;
increment(glvn,subs,incr) ;increment the number in a global node
 n $et s $et="zg "_$zl_":error^node"
 ;
 n globalname,increment,ok,return
 ;
 s globalname=$$construct(glvn,.subs)
 s increment=$i(@globalname,$g(incr,1))
 s ok=1
 ;
 s return="{""ok"": "_ok_", ""global"": """_glvn_""","
 s return=return_" ""data"": "_increment_"}"
 ;
 quit return
 ;
 ;
merge() ;
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit ""
 ;
 ;
globalDirectory() ;
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit ""
 ;
 ;
lock() ;
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit ""
 ;
 ;
unlock() ;
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit ""
 ;
 ;
function(func,args) ;call an arbitrary extrinsic function
 n $et s $et="zg "_$zl_":error^node"
 ;
 n dev,function,ok,result,return
 ;
 i '$d(args)#10 s args=""
 s:args'="" args=$$parse(args)
 ;
 s io=$io
 s dev="/dev/null"
 o dev u dev
 ;
 s function=func_$s(args'="":"("_args_")",1:"")
 x "s result=$$"_function
 ;
 c dev u io
 ;
 i result'=+result s result=""""_result_""""
 s ok=1
 ;
 s return="{""ok"": "_ok_", ""function"": """_func_""","
 i $g(args)'="" s return=return_" ""arguments"": ["_args_"],"
 s return=return_" ""result"": "_result_"}"
 ;
 quit return
 ;
 ;
retrieve() ;
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit ""
 ;
 ;
update() ;
 n $et s $et="zg "_$zl_":error^node"
 ;
 quit ""
 ;
 ;
error ;
 s $ec=""
 ;
 n error
 ;
 s error="{""ok"": 0, ""errorCode"": "_$p($zs,",")_", "
 s error=error_"""errorMessage"": """_$p($p($zs," ",2,$l($zs," ")),":")_"""}"
 ;
 quit error
 ;
 ;
