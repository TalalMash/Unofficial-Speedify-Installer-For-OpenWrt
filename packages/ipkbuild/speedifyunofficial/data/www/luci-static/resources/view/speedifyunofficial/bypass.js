'require uci';
'require fs';
'require ui';
'require rpc';
'require form';
'require view';
'require network';
'require validation';
'require tools.widgets as widgets';

var bin = "/usr/share/speedify/speedify_cli";
var args = ['show', 'streamingbypass'];

return view.extend({
        formdata: { wol: {} },

        load: function () {
                return Promise.all([
                        fs.exec_direct(bin, args, "json").then(function (res) {
                                return res
                        }),
                        L.resolveDefault(fs.stat(bin))
                ]);
        },

        handleAddPort: function () {
                var portaddition = document.getElementById("portaddition").value;
                var protoaddition = document.getElementById("protoaddition").value;
                var spdarg = portaddition + "/" + protoaddition;
                fs.exec_direct(bin, ['streamingbypass', 'ports', 'add', spdarg]).then(function () {
                        window.location.reload();
                });
        },

        handleDeletePort: function (domain) {
                if (domain.portRangeEnd) {
                        var spdarg = domain.port + '-' + domain.portRangeEnd + '/' + domain.protocol,
                                args = ['streamingbypass', 'ports', 'rem', spdarg]
                } else {
                        spdarg = domain.port + "/" + domain.protocol,
                                args = ['streamingbypass', 'ports', 'rem', spdarg]
                }
                fs.exec_direct(bin, args).then(function () {
                        window.location.reload();
                });
        },

        handleAddDomain: function () {
                var domainAddition = document.getElementById("domainaddition").value;
                var spdarg = domainAddition;
                fs.exec_direct(bin, ['streamingbypass', 'domains', 'add', spdarg]).then(function () {
                        window.location.reload();
                });
        },

        handleDeleteDomain: function (domain) {
                args = ['streamingbypass', 'domains', 'rem', domain]
                fs.exec_direct(bin, args).then(function () {
                        window.location.reload();
                });
        },

        handleAddIPv4: function () {
                var IPv4Addition = document.getElementById("ipv4addition").value;
                var spdarg = IPv4Addition;
                fs.exec_direct(bin, ['streamingbypass', 'ipv4', 'add', spdarg]).then(function () {
                        window.location.reload();
                });
        },

        handleDeleteIPv4: function (domain) {
                args = ['streamingbypass', 'ipv4', 'rem', domain]
                fs.exec_direct(bin, args).then(function () {
                        window.location.reload();
                });
        },

        handleAddIPv6: function () {
                var IPv6Addition = document.getElementById("ipv6addition").value;
                var spdarg = IPv6Addition;
                fs.exec_direct(bin, ['streamingbypass', 'ipv6', 'add', spdarg]).then(function () {
                        window.location.reload();
                });
        },

        handleDeleteIPv6: function (domain) {
                args = ['streamingbypass', 'ipv6', 'rem', domain]
                fs.exec_direct(bin, args).then(function () {
                        window.location.reload();
                });
        },

        renderBypass: function (data) {
                var ports = Array.isArray(data[0].ports) ? data[0].ports : [];
                var domains = Array.isArray(data[0].ports) ? data[0].domains : [];
                var ipv4 = Array.isArray(data[0].ports) ? data[0].ipv4 : [];
                var ipv6 = Array.isArray(data[0].ports) ? data[0].ipv6 : [];

                //PORTS
                var portstable = E('table', { 'class': 'table lases' }, [
                        E('tr', { 'class': 'tr table-titles' }, [
                                E('th', { 'class': 'th' }, _('Port')),
                                E('th', { 'class': 'th' }, _('Protocol')),
                                E('th', { 'class': 'th' }, _('Action'))
                        ])
                ]);

                cbi_update_table(portstable,
                        ports.map(function (domain) {
                                var rows;
                                rows = [
                                        domain.portRangeEnd ? domain.port + '-' + domain.portRangeEnd : domain.port,
                                        domain.protocol
                                ];
                                rows.push(E('button', {
                                        'class': 'cbi-button cbi-button-negative',
                                        'click': L.bind(this.handleDeletePort, this, domain)
                                }, [_('Delete')]));
                                return rows;
                        }, this));

                var portAddition = E('input', { 'id': 'portaddition', 'type': "text", 'style': 'width: 150px' });
                var protoAddition = E('select', { 'id': 'protoaddition', 'style': 'width: 70px; margin-left: 10px' }, [
                        E('option', { 'value': 'tcp' }, _('TCP')),
                        E('option', { 'value': 'udp' }, _('UDP'))
                ]);
                var addbutton = E('button', {
                        'class': 'cbi-button cbi-button-positive',
                        'click': L.bind(this.handleAddPort, this),
                        'style': 'margin-left: 10px; padding: 0 26px;'
                }, [_('Add')]);
                //PORTS-end
                //DOMAINS
                var domainstable = E('table', { 'class': 'table lases' }, [
                        E('tr', { 'class': 'tr table-titles' }, [
                                E('th', { 'class': 'th' }, _('Domains')),
                                E('th', { 'class': 'th' }, _('Action'))
                        ])
                ]);

                cbi_update_table(domainstable,
                        domains.map(function (domain) {
                                var rows;
                                rows = [
                                        domain
                                ];
                                rows.push(E('button', {
                                        'class': 'cbi-button cbi-button-negative',
                                        'click': L.bind(this.handleDeleteDomain, this, domain)
                                }, [_('Delete')]));
                                return rows;
                        }, this));

                var domainAddition = E('input', { 'id': 'domainaddition', 'type': "text", 'style': 'width: 150px' });
                var domainAddButton = E('button', {
                        'class': 'cbi-button cbi-button-positive',
                        'click': L.bind(this.handleAddDomain, this),
                        'style': 'margin-left: 10px; padding: 0 26px;'
                }, [_('Add')]);
                //DOMAINS-end
                //IPv4
                var ipv4table = E('table', { 'class': 'table lases' }, [
                        E('tr', { 'class': 'tr table-titles' }, [
                                E('th', { 'class': 'th' }, _('IPv4')),
                                E('th', { 'class': 'th' }, _('Action'))
                        ])
                ]);

                cbi_update_table(ipv4table,
                        ipv4.map(function (domain) {
                                var rows;
                                rows = [
                                        domain
                                ];
                                rows.push(E('button', {
                                        'class': 'cbi-button cbi-button-negative',
                                        'click': L.bind(this.handleDeleteIPv4, this, domain)
                                }, [_('Delete')]));
                                return rows;
                        }, this));

                var IPv4Addition = E('input', { 'id': 'ipv4addition', 'type': "text", 'style': 'width: 150px' });
                var IPv4AddButton = E('button', {
                        'class': 'cbi-button cbi-button-positive',
                        'click': L.bind(this.handleAddIPv4, this),
                        'style': 'margin-left: 10px; padding: 0 26px;'
                }, [_('Add')]);
                //IPv4-end
                //IPv6
                var ipv6table = E('table', { 'class': 'table lases' }, [
                        E('tr', { 'class': 'tr table-titles' }, [
                                E('th', { 'class': 'th' }, _('IPv6')),
                                E('th', { 'class': 'th' }, _('Action'))
                        ])
                ]);

                cbi_update_table(ipv6table,
                        ipv6.map(function (domain) {
                                var rows;
                                rows = [
                                        domain
                                ];
                                rows.push(E('button', {
                                        'class': 'cbi-button cbi-button-negative',
                                        'click': L.bind(this.handleDeleteIPv6, this, domain)
                                }, [_('Delete')]));
                                return rows;
                        }, this));

                var IPv6Addition = E('input', { 'id': 'ipv6addition', 'type': "text", 'style': 'width: 150px' });
                var IPv6AddButton = E('button', {
                        'class': 'cbi-button cbi-button-positive',
                        'click': L.bind(this.handleAddIPv6, this),
                        'style': 'margin-left: 10px; padding: 0 26px;'
                }, [_('Add')]);
                //IPv6-end

                return E([
                        E('h2', _("Speedify's Bypass Service")),
                        E('p', _('<br>‣ Speedify will dynamically choose the best WAN for bypass depending on data caps and priority as well as failover.<br>‣ Navigate to <i>VPN->VPN Policy Routing</i> for static client/WAN specific settings.<br>')),
                        E('h3', _('Ports')),
                        portstable,
                        E('p', _('• <b>Examples:</b><br>- Single: 1234<br>- Range: 1210-1220')),
                        portAddition,
                        protoAddition,
                        addbutton,
                        E('h3', _('Domains')),
                        domainstable,
                        domainAddition,
                        domainAddButton,
                        E('h3', _('Remote IPv4 addresses')),
                        ipv4table,
                        IPv4Addition,
                        IPv4AddButton,
                        E('h3', _('Remote IPv6 addresses')),
                        ipv6table,
                        IPv6Addition,
                        IPv6AddButton
                ])
        },

        handleSave: null,
        handleSaveApply: null,
        handleReset: null,

        render: function (data) {
                return this.renderBypass(data)
        }
});