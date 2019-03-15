################################################################################
# Tenant and Environment Specific Variables
################################################################################

. /home/callidus/.bash_profile

# Tenant Specific
tenantid="tels"
tenantid_uc="TELS"

# Env specific
custinst="uat"
custinst_uc="UAT"
infa_username="Administrator"		# informatica username
infa_password="Ja9JOzKvR1"			# informatica password
lpdb_username="telsadmin"			# landing pad database username
lpdb_password="telsadmin"			# landing pad database password
gpgcodemap="AAAAAAA"				# code map for encryption
delaytimer="300"    				# delay in the time for file processing

# Global
. /apps/Callidus/tels/integrator/tels_setenv_global_vars.sh
