#include "wlr-includes.hpp"
#include <getopt.h>
#include "server.hpp"


int main(int argc, char* argv[]) {
//#ifdef DEBUG
	wlr_log_init(WLR_DEBUG, nullptr);
//#endif

	while ((getopt(argc, argv, "")) != -1);
	const char* startup_cmd = optind == argc ? "" : argv[optind];
	ZenithServer::instance()->run(startup_cmd);
}
