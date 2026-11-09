exports.register = function () {
    this.register_hook(
        "connect",
        "allow_local_relay"
    );
};


exports.allow_local_relay = function (
    next,
    connection
) {
    const remoteIp =
        connection?.remote?.ip ||
        connection?.remote?.addr ||
        "";


    if (
        remoteIp === "127.0.0.1" ||
        remoteIp === "::1" ||
        remoteIp === "::ffff:127.0.0.1"
    ) {
        connection.relaying = true;

        this.loginfo(
            connection,
            "Allowing localhost relay"
        );
    }


    next();
};
