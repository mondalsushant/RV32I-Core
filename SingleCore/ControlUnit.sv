module ControlUnit(
    input logic [6:0] opcode, // Instruction[6:0]
    input logic [2:0] funct3,  // Instruction[14:12]
    input logic funct7b5, // Instruction[30]
    output logic reg_write,
    output logic alu_src, // 0=rs2, 1=immediate
    output logic [2:0] imm_sel,
    output logic mem_write,
    output logic mem_read,
    output logic branch,
    output logic jump,
    output logic jalr,
    output logic [1:0] result_src, // 0 = ALU, 1 = MEM, 2 = PC + 4
    output logic [3:0] ALU_Sel
);
    typedef enum logic [3:0] {
        ADD = 4'b0000,
        SUB = 4'b0001,
        AND = 4'b0010,
        OR = 4'b0011,
        XOR = 4'b0100,
        SLT = 4'b0101,
        SLTU = 4'b0110,
        SLL = 4'b0111,
        SRL = 4'b1000,
        SRA = 4'b1001,
        PASSB = 4'b1010
    } aluops;

    typedef enum logic [6:0] {
        R = 7'b0110011,
        I = 7'b0010011,
        L = 7'b0000011, // Load
        S = 7'b0100011, // Store
        B = 7'b1100011, // Branch
        JAL = 7'b1101111, // Jump and Link
        JALR = 7'b1100111, // Jump and Link Register
        LUI = 7'b0110111, // Load Upper Immediate
        AUIPC = 7'b0010111
    } opcodes;

    always_comb begin
        reg_write = 1'b0; alu_src = 1'b0; imm_sel = 3'b000; mem_write = 1'd0; mem_read = 1'b0; branch = 1'b0; jump = 1'b0; jalr = 1'b0; result_src = 2'b00; ALU_Sel = 4'b0000;
        case (opcodes'(opcode))
            R: begin
                reg_write = 1'b1;
                imm_sel = 3'bxxx;
                case (funct3)
                    3'b000: ALU_Sel = (funct7b5) ? SUB: ADD;
                    3'b001: ALU_Sel = SLL;
                    3'b010: ALU_Sel = SLT;
                    3'b011: ALU_Sel = SLTU;
                    3'b100: ALU_Sel = XOR;
                    3'b101: ALU_Sel = (funct7b5) ? SRA: SRL;
                    3'b110: ALU_Sel = OR;
                    3'b111: ALU_Sel = AND;
                    default: ALU_Sel = 4'bxxxx;
                endcase
            end
            I: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                imm_sel = 3'b000;
                case (funct3)
                    3'b000: ALU_Sel = ADD;
                    3'b001: ALU_Sel = SLL;
                    3'b010: ALU_Sel = SLT;
                    3'b011: ALU_Sel = SLTU;
                    3'b100: ALU_Sel = XOR;
                    3'b101: ALU_Sel = (funct7b5) ? SRA: SRL;
                    3'b110: ALU_Sel = OR;
                    3'b111: ALU_Sel = AND;
                    default: ALU_Sel = 4'bxxxx;
                endcase
            end
            L: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                mem_read = 1'b1;
                result_src = 2'b01;
                imm_sel = 3'b000;
            end
            S: begin
                alu_src = 1'b1;
                imm_sel = 3'b001;
                mem_write = 1'b1;
                result_src = 2'bxx;
            end
            B: begin
                imm_sel = 3'b010;
                branch = 1'b1;
                case (funct3)
                    3'b000, 3'b001: ALU_Sel = SUB;
                    3'b100, 3'b101: ALU_Sel = SLT; 
                    3'b110, 3'b111: ALU_Sel = SLTU; 
                    default: ALU_Sel = 4'bxxxx;
                endcase
                result_src = 2'bxx;
            end
            JAL: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                imm_sel = 3'b100;
                jump = 1'b1;

                result_src = 2'b10;
            end
            JALR: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                jump = 1'b1;
                jalr = 1'b1;
                result_src = 2'b10;
                imm_sel = 3'b000;
            end
            LUI, AUIPC : begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                imm_sel = 3'b011;
                ALU_Sel = (opcode[5]) ? PASSB:ADD;
            end
            default: ;
        endcase
    end
endmodule