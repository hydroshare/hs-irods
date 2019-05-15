
#
# The second parameter is always the absoluted path of the "bags" directory
# e.g. /hydroshareuserZone/home/localHydroProxy/bags => from "bags"'s path we could analyze to have:
#      1. Where is used to store HS users usage: /hydroshareuserZone/home/localHydroProxy/bags
#      2. The HydroShare Root Dir: /hydroshareuserZone/home/localHydroProxy
#      3. The iRODS home directory for all local users: /hydroshareuserZone/home
#      4. All others directory inside iRODS home directory are needed to scan
#
# The last parameter is server role which is used to determine the iRODS server is HydroShare Data Sever or Federated Server
#      1. If its value is "HydroShare" => the server acts as the HydroShare Data Server and micro-services only take care files on HydroShare Root Dir
#      2. Otherwise, the server's role is a Federated Server and micro-services will take care files on the iRODS home directory
##

# catch "irm" command
acDataDeletePolicy () {
    msiHSRemoveFile($objPath, "/hydroshareuserZone/home/localHydroProxy/bags", "quotaUserName", "Federated", "admin", "default", "FQDN_OR_IP/hsapi/_internal/update_quota_usage/");
}

# catch "icp" command
acPostProcForCopy () {
    msiHSAddNewFile($objPath, "/hydroshareuserZone/home/localHydroProxy/bags", "quotaUserName", "Federated", "admin", "default", "FQDN_OR_IP/hsapi/_internal/update_quota_usage/");
}

# catch "imv" command
#acPostProcForObjRename (*sourceObject, *destObject) {
#    msiHSRemoveFile(*sourceObject, "/hydroshareuserZone/home/localHydroProxy/bags", "quotaUserName", "Federated", "admin", "default", "FQDN_OR_IP/hsapi/_internal/update_quota_usage/");
#    msiHSAddNewFile(*destObject,   "/hydroshareuserZone/home/localHydroProxy/bags", "quotaUserName", "Federated", "admin", "default", "FQDN_OR_IP/hsapi/_internal/update_quota_usage/");
#}

# catch "iput" command
acPostProcForPut () {
    msiHSAddNewFile($objPath, "/hydroshareuserZone/home/localHydroProxy/bags", "quotaUserName", "Federated", "admin", "default", "FQDN_OR_IP/hsapi/_internal/update_quota_usage/");
}

# catch "imeta" command if any new "quotaUserName" or "resetQuotaDir" are set
acPostProcForModifyAVUMetadata (*cmd, *objType, *objPath, *avuName, *avuValue, *avuUnit) {
    # set a new quotaHolder to a Collection: will affect to all COLL inside HydroShare Root Dir
    if (((*cmd == "set") || (*cmd == "add")) && (*objType == "-C") && (*avuName == "quotaUserName"))
    then {
        msiHSAddQuotaHolder(*objPath, "/hydroshareuserZone/home/localHydroProxy/bags", *avuValue, "Federated", "admin", "default", "FQDN_OR_IP/hsapi/_internal/update_quota_usage/");
    }

    # could be set in anywhere, in any object.
    # micro-services will scan from the HydroShare Root Dir or the iRODS home directory depend on the last parameter is "HydroShare" or other value.
    if (((*cmd == "set")  || (*cmd == "add")) && (*objType == "-C") && (*avuName == "resetQuotaDir"))
    then {
        msiHSResetQuotaDir(*objPath, "/hydroshareuserZone/home/localHydroProxy/bags", "quotaUserName", "Federated", "admin", "default", "FQDN_OR_IP/hsapi/_internal/update_quota_usage/");
    }

}

# catch "imeta" command if any "quotaUserName" AVU is removed
acPreProcForModifyAVUMetadata (*cmd, *objType, *objPath, *avuName, *avuValue, *avuUnit) {
    if ((*cmd == "rm") && (*objType == "-C") && (*avuName == "quotaUserName"))
    then {
        msiHSRemoveQuotaHolder(*objPath, "/hydroshareuserZone/home/localHydroProxy/bags", *avuValue, "Federated", "admin", "default", "FQDN_OR_IP/hsapi/_internal/update_quota_usage/");
    }
}

