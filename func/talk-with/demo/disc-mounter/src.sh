#! /usr/bin/env sh

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

disc_mounter ()
{
    : :: demos
    
    : disc_mounter _ /dev/sde /var/lib/libvirt/images/pool-yhm
    
    : disc_mounter funs dev_uuid /dev/sde UUID
    : disc_mounter funs dev_uuid /dev/sde TYPE
    
    : disc_mounter funs uuid_fstab /dev/sde /var/lib/libvirt/images/pool-yhm
    
    : disc_mounter steps step0_mkdir /var/lib/libvirt/images/pool-yhm
    
    : :: need to using in '()'
    : :: e.g. '(disc_mounter funs dev_uuid /dev/sde UUID)'
    
    
    : :::: :
    
    
    funs ()
    {
        : funs 是对功能封装 必须传参 （默认值只用来调试） 只转换数据而不做任何事 （无副作用）
        
        : funs dev_uuid /dev/sde UUID
        : funs uuid_fstab /dev/sde /path/to/dir
        
        : ::: :
        
        
        dev_uuid ()
        {
            : dev_uuid /dev/sde UUID
            : dev_uuid /dev/sde TYPE
            
            : :: :
            
            
            local device="$1" &&
            local field="$2" &&
            (eval "$(blkid -o export -- "$device")"' ; echo $'"${field:-UUID}") &&
            
            :;
            
        } &&
        
        uuid_fstab ()
        {
            : uuid_fstab /dev/sde /path/to/dir
            : uuid_fstab /dev/sda3 /path/to/dir/some-pool
            
            : :: :
            
            local device="$1" &&
            local dir="${2:-/var/lib/docker}" &&
            
            echo UUID="$(
                dev_uuid "$device" UUID )"  "${dir:-/var/lib/containers}"  "$(
                dev_uuid "$device" TYPE )"  defaults,pquota  0 0 &&
            
            :;
            
        } &&
        
        "$@" &&
        
        :;
        
    } &&
    
    
    
    
    
    : TODO: 可以有一些用 eval 做的位置参数批量生成 &&
    
    
    steps ()
    {
        : steps 是把执行步骤封装 不传参 （只能进 main 的参数 传参仅用于调试）
        
        : ::: :
        
        step0_mkdir ()
        {
            local dir="${1:-$dir}" &&
            
            mkdir -p -- "$dir" &&
            
            :;
            
        } &&
        
        : 下边都是如果回答 n 就退出'(quit)' disc_mounter 否则就会执行到下边 &&
        
        step1_mkfs ()
        {
            local device="${1:-$device}" &&
            local dir="${2:-$dir}" &&
            
            
            ask_user "
$(lsblk)

========

: got 
: 
:   dev: $device 
:   dir: $dir 
" ": make the $device in to xfs ? will clear datas in it ~~ 😬" "[y/n]" '
                
                case "$ans" in 
                    y) echo ; return 0 ;; 
                    n) echo : quit tool 😋 ; return 2 ;;
                    *) ;; esac ' || return ;
            
            mkfs -t xfs -n ftype=1 -f -- "$device" &&
            
            :;
            
        } &&
        
        step2_appendfstab ()
        {
            local device="${1:-$device}" &&
            local dir="${2:-$dir}" &&
            
            
            
            ask_user "
: will add this line to fstab:
$(uuid_fstab "$device" "$dir")
" ': 🤔 go on ?' '[y/n]' '
                
                case "$ans" in
                    y) echo ; return 0 ;;
                    n) echo : quit tool 😘 ; return 2 ;;
                    *) ;; esac ' || return ;
            
            (echo ; uuid_fstab "$device" "$dir" ; echo) | tee -a -- /etc/fstab &&
            
            :;
            
        } &&
        
        step3_mount ()
        {
            mount -a ||
            { rt=$? ; echo 😨 may need to check /etc/fstab and recmd mount -a ; return $rt ; } ;
            
            lsblk &&
            
            :;
            
        } &&
        
        "$@" &&
        
        :;
        
    } &&
    
    alias _=main &&
    
    main ()
    {
        local rt ;
        
        case "$#" in 1|2) ;; *) 1>&2 echo need one or two args ; return 4 ;; esac ;
        
        
        
        local device="$1" && shift 1 &&
        local dir="$1" && shift 1 &&
        
        
        
        : &&
        (
            
            export device="${device:-}" &&
            export dir="${dir:-/var/lib/libvirt/images/pool0}" &&
            
            
            
            steps step0_mkdir &&
            steps step1_mkfs &&
            steps step2_appendfstab &&
            steps step3_mount &&
            
            : ) &&
        
        :;
        
    } &&
    
    ("$@") &&
    
    :;
    
} ;
