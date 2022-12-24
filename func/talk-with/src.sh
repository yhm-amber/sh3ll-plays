ask_user ()
{
    : ask_user "msgs" "quest xx ?" "[y/n] (kk)" 'case "$ans" in y|n) echo "$ans" ; break ;; *) printf %s," " "${ans:-${ans_tmp:-kk}}" ;; esac'
    
    local pre_desc="$1" && shift 1 &&
    local ask="$1" && shift 1 &&
    local anser_set="$1" && shift 1 &&
    local cases="$1" && shift 1 &&
    
    : || { >&2 echo warn: args not enough. ; } ;
    
    
    local pre_desc="${pre_desc:-Hey 👻}" &&
    local ask="${ask:-what should i ask ???}" &&
    local anser_set="${anser_set:-[y/n] (:p)}" &&
    
    local cases="${cases:-
        case \"\$ans\" in 
            
            y|\'\') echo 😦 yup\?\? ; break ;; 
            n) echo 🤔 no\? ; break ;; 
            *) echo 🤨 ahh\? what is \'\$"{"ans:-:p"}"\' \? ;; esac }" &&
    
    
    
    echo "$pre_desc" &&
    
    while read -p "$ask $anser_set " -- ans ;
    do ans_tmp="${ans:-$ans_tmp}" eval "$cases" ; done &&
    
    :;
    
} ;



