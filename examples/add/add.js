module.exports = {
    top: 'add',
    topFile: 'add.v',
    targets: [{
        data:  't_0_dat',
        valid: 't_0_req',
        ready: 't_0_ack',
        width: 32,
        length: 16,
        formula: width => i => i,
    },{
        data:  't_1_dat',
        valid: 't_1_req',
        ready: 't_1_ack',
        width: 32,
        length: 16,
        formula: width => i => i,
    }],
    initiators: [{
        data:  'i_0_dat',
        valid: 'i_0_req',
        ready: 'i_0_ack',
        width: 32
    }]
};
