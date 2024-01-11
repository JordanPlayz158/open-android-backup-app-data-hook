# Made on release 1.0.15

APP_DATA_ROOT_HOOK_DIRECTORY="/backup-tmp/Hooks/app_data_root/"

# This function is ran after the script copies the internal storage, contacts, apps and other data.
# You can use it to get more data from your device.
function backup_hook() {
    mkdir -p .$APP_DATA_ROOT_HOOK_DIRECTORY # create directory structure

    if is_root;
    then
        get_file /data/data/ . .$APP_DATA_ROOT_HOOK_DIRECTORY # get a directory
    else
        cecho "Cannot back up application data, cannot run adb as root"
    fi
}

# In the after backup hook, you can get the backup archive path using $backup_archive.
# This is useful for uploading your backups to the cloud, among other things.
function after_backup_hook() {
  :
}

# This function is ran after restoring the internal storage, apps and contacts to the device.
function restore_hook() {
    # if the directory exists, proceed
    if [ -d ".$APP_DATA_ROOT_HOOK_DIRECTORY" ]; then
        if is_root;
        then
            adb push .$APP_DATA_ROOT_HOOK_DIRECTORY /data/data/
        else
            cecho "Cannot restore application data, cannot run adb as root"
        fi
    else
        cecho "Skipping restore hook - application data directory doesn't exist in this backup."
    fi
}

function is_root() {
    adb_root_output=$(adb root)
    if [[ "$adb_root_output" == "adbd is already running as root" ]] || [[ "$adb_root_output" == "restarting adbd as root" ]]
    then
        true
        return
    fi

    cecho "adb could not be run as root due to '$adb_root_output'"
    false
    return
}
