# Makefile for tensorflow plugin for MLDB

# External repos required
$(eval $(call include_sub_make,mongodb_ext,ext,mongodb_ext.mk))

# Mongodb plugin
LIBMLDB_MONGODB_PLUGIN_SOURCES:= \
	mongodb_plugin.cc \

$(eval $(call set_compile_option,$(LIBMLDB_MONGODB_PLUGIN_SOURCES),$(MONGOCXX_INCLUDE_FLAGS)))

$(eval $(call mldb_plugin_library,mongodb,mldb_mongodb_plugin,$(LIBMLDB_MONGODB_PLUGIN_SOURCES),mongocxx))

$(eval $(call mldb_builtin_plugin,mongodb,mldb_mongodb_plugin,doc))

$(eval $(call mldb_unit_test,MLDB-1413-mongodb-plugin.js,mongodb,manual))
