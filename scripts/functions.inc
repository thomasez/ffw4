
#
# If we are in scripts, move back one.
#
base_directory() {

    pwd
    cd $(pwd | sed -e "s/scripts$//")/$1
    pwd

}
