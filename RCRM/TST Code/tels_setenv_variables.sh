################################################################################
# Tenant and Environment Specific Variables
################################################################################

. /home/callidus/.bash_profile

# Tenant Specific
tenantid="tels"
tenantid_uc="TELS"

# Env specific
custinst="tst"
custinst_uc="TST"
infa_username="Administrator"		# informatica username
infa_password="tf8AnHYKYh"			# informatica password
lpdb_username="telsadmin"			# landing pad database username
lpdb_password="telsadmin"			# landing pad database password
lpdb_connstring="telstst"           # 13-Feb-2019: DB connection string for sqlplus
gpgcodemap="AAAAAAA"				# code map for encryption
delaytimer="300"    				# delay in the time for file processing

# Global
. /apps/Callidus/tels/integrator/tels_setenv_global_vars.sh