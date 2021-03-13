gf_exp = [0] * 512
gf_log = [0] * 256

def gf_mult_noLUT(x, y, prim=0, field_charac_full=256, carryless=True):
    
    r = 0
    while y: # while y is above 0
        if y & 1: r = r ^ x if carryless else r + x
        y = y >> 1 # equivalent to y // 2
        x = x << 1 # equivalent to x*2
        if prim > 0 and x & field_charac_full: 
            x = x ^ prim

    return r

def init_tables(prim=0x11d):
    global gf_exp, gf_log
    gf_exp = [0] * 512 # anti-log (exponential) table
    gf_log = [0] * 256 # log table
    
    x = 1
    for i in range(0, 255):
        gf_exp[i] = x 
        gf_log[x] = i # compute log at the same time
        x = gf_mult_noLUT(x, 2, prim)

        
    for i in range(255, 512):
        gf_exp[i] = gf_exp[i - 255]
    return [gf_log, gf_exp]
    
def gf_poly_mul(p,q):
    r = [0] * (len(p)+len(q)-1)
    for j in range(0, len(q)):
        for i in range(0, len(p)):
            r[i+j] ^= gf_mul(p[i], q[j])
    return r
    
def rs_generator_poly(nsym):
    g = [1]
    for i in range(0, nsym):
        g = gf_poly_mul(g, [1, gf_pow(2, i)])
    return g
    
def gf_pow(x, power):
    return gf_exp[(gf_log[x] * power) % 255]
    
def gf_mul(x,y):
    if x==0 or y==0:
        return 0
    return gf_exp[gf_log[x] + gf_log[y]]

def formatStringGen():
    return [1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1]
    
def rs_encode_msg(msg_in, nsym, formatString=False):
    if (len(msg_in) + nsym) > 255: raise ValueError("Message is too long (%i when max is 255)" % (len(msg_in)+nsym))
    gen = rs_generator_poly(nsym)
    if formatString:
        gen = formatStringGen()
    print(gen)
    msg_out = [0] * (len(msg_in) + len(gen)-1)
    msg_out[:len(msg_in)] = msg_in

    # Synthetic division main loop
    for i in range(len(msg_in)):
        coef = msg_out[i]

        if coef != 0:
            for j in range(1, len(gen)):
                msg_out[i+j] ^= gf_mul(gen[j], coef)

    msg_out[:len(msg_in)] = msg_in

    return msg_out
    
if __name__ == "__main__":
    init_tables()
    #mi = [32,91,11,120,209,114,220,77,67,64,236,17,236,17,236,17]
    #mi = [64, 210, 117, 71, 118, 23, 50, 6, 39, 38, 150, 198, 198, 150, 112, 236]

    mi = [0, 0, 0, 0, 1]
    
    mo = rs_encode_msg(mi, 10, True)
    
    for i in mo:
        print(i)

    
