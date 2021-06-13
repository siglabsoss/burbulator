module.exports = {
    top: 'eb0',
    topFile: 'eb0.sv',
    clk: 'clock1',
    reset: 'reset1', // active high
    targets: [{
        data:  't_0_dat',
        valid: 't_0_req',
        ready: 't_0_ack',
        formula: width => {
            const words = (width / 32) >>> 0;
            return () => {
                let res = '';
                for (let i = 0; i < words; i++) {
                    res += ('000000' +
                        (Math.pow(2, 32) * Math.random() >>> 0)
                    ).slice(-8)
                }
                return res;
            };
        },
        width: 128,
        length: 128
    }],
    initiators: [{
        data:  'i_0_dat',
        valid: 'i_0_req',
        ready: 'i_0_ack',
        width: 128
    }]
};
