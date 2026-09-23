// Suporte para pendurar o power bank Xiaomi Mi 50W 20000mAh (PB2050SZM) em um tripé.
//
// O power bank fica em pé dentro de um "berço" aberto em cima (portas para cima)
// e o berço prende no tripé de uma destas formas (escolha em `fixacao`):
//   "clip"      - abraçadeira de encaixe (snap) para tubo redondo: coluna central do tripé.
//   "mosquetao" - gancho aberto (tipo mosquetão) que se pendura na pontinha arredondada
//                 da peça da haste (aquela com os 2 furos ovais), apoiando na base dela.
//                 Tem um nub oval que entra no furo de baixo só para não escorregar de lado.
//   "nenhum"    - só o berço, com rasgos para passar fita de velcro/abraçadeira.
// Os rasgos de velcro existem em todas as versões, como reforço.
//
// MEÇA SEU TRIPÉ com paquímetro antes de imprimir.

/* [Fixação] */
fixacao = "mosquetao";   // ["clip", "mosquetao", "nenhum"]

/* [Clip - tubo redondo] */
diametro_tubo = 25;      // diâmetro da coluna central (mm) - MEDIR
altura_clip = 40;        // altura da abraçadeira
abertura_clip = 0.82;    // abertura da boca do clip, fração do diâmetro (menor = aperta mais)

/* [Mosquetão - pontinha arredondada da haste] */
raio_ponta   = 7;        // raio da pontinha arredondada onde o mosquetão pendura (mm) - MEDIR
espessura_peca = 4.5;    // espessura (grossura) dessa pontinha (mm) - MEDIR
largura_mosquetao = 14;  // largura do gancho (ao longo da haste)
abertura_mosquetao = 0.62; // abertura da garganta, fração do raio (menor = mais fechado/seguro)
usar_nub = true;         // nub oval que entra no furo de baixo, só para travar lateralmente
furo_largura = 8.3;      // largura do furo oval (mm)
furo_altura  = 14.2;     // altura do furo oval (mm)
folga_nub = 1.2;         // folga do nub no furo (encaixe frouxo, não é snap-fit)
distancia_furo_ponta = 10; // distância do centro do furo de baixo até o centro da pontinha arredondada - MEDIR

/* [Power bank - medidas oficiais 154 x 74 x 28 mm] */
pb_largura   = 74;
pb_espessura = 28;
pb_raio      = 6;        // raio dos cantos arredondados
folga        = 0.8;      // folga por lado (PETG/PLA: 0.6 a 1.0)

/* [Berço] */
parede      = 2.4;
fundo       = 2.4;
altura_berco = 95;       // o power bank tem 154 mm: sobram ~60 mm para fora (portas e LEDs livres)
janela_larg = 46;        // janela frontal (mostra o logo e deixa empurrar para tirar)
janela_base = 14;
fixacao_z = altura_berco - 20; // altura do centro da fixação na parede traseira

$fn = 64;

iw = pb_largura + 2*folga;
it = pb_espessura + 2*folga;
ir = pb_raio + folga;
ow = iw + 2*parede;
ot = it + 2*parede;
orad = ir + parede;
ybk = it + parede;       // face traseira (externa) do berço

module rrect(w, t, r, h) {
    // retângulo arredondado centrado em X, de y=0 a y=t
    translate([0, t/2, 0]) linear_extrude(h)
        offset(r=r) square([w - 2*r, t - 2*r], center=true);
}

module berco() {
    difference() {
        translate([0, -parede, 0]) rrect(ow, ot, orad, altura_berco);
        translate([0, 0, fundo]) rrect(iw, it, ir, altura_berco);
        translate([-janela_larg/2, -parede - 1, janela_base])
            cube([janela_larg, parede + 2, altura_berco]);
        translate([0, it/2, -1]) linear_extrude(fundo + 2)
            offset(r=4) square([iw - 30, it - 16], center=true);
        for (z = [22, altura_berco - 22])
            for (s = [-1, 1])
                translate([s*(iw/2 - 12) - 2, it - 1, z - 13])
                    cube([4, parede + 2, 26]);
    }
}

// ---------- anel aberto (C) reutilizável: usado no clip e no mosquetão ----------
module anel_aberto(r_in, esp, boca_frac, larg, base) {
    r_out = r_in + esp;
    boca  = 2 * r_in * boca_frac;
    cy    = ybk + base + r_in;
    difference() {
        union() {
            translate([0, cy, 0]) rotate([-90, 0, 0]) cylinder(r=r_out, h=larg, center=true);
            translate([-larg/2, ybk - 0.5, -r_out])
                cube([larg, base + r_in*0.6, r_out]);
        }
        translate([0, cy, 0]) rotate([-90, 0, 0]) cylinder(r=r_in, h=larg + 2, center=true);
        translate([-boca/2, cy, -r_out - 1]) cube([boca, r_out + 2, r_out + 1]);
    }
}

module clip() {
    translate([0, 0, fixacao_z])
        anel_aberto(diametro_tubo/2, 3.6, abertura_clip, altura_clip, 6);
}

// ---------- mosquetão: pendura na pontinha arredondada da haste ----------
module oval(w, h) {
    hull() {
        translate([0,  (h - w)/2]) circle(d = w);
        translate([0, -(h - w)/2]) circle(d = w);
    }
}

module mosquetao() {
    translate([0, 0, fixacao_z])
        anel_aberto(raio_ponta, espessura_peca * 0.9, abertura_mosquetao, largura_mosquetao, 3);
    if (usar_nub) {
        // nub oval frouxo que entra no furo de baixo, só para não balançar de lado
        nl = furo_largura - folga_nub;
        na = furo_altura  - folga_nub;
        translate([0, 0, fixacao_z - distancia_furo_ponta])
            translate([0, ybk - 0.01, 0]) rotate([-90, 0, 0])
                linear_extrude(espessura_peca + 1.5) oval(nl, na);
    }
}

color([1,0.55,0.1]) berco();
color([1,0.55,0.1]) if (fixacao == "clip") clip();
color([1,0.55,0.1]) if (fixacao == "mosquetao") mosquetao();
