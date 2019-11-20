function [freq s11_PNA s11_GEN s21_PNA s21_GEN S11_error S21_error S11_thresh S21_thresh] = error_plot()
    %Caleb Carr
    %Advanced Radar Research Center | Norman, OK
    %Returns S11 and S21 from two S2P files, error between these two
    %and the number of points below the error threshold
    clf;
    %Grab both S2P files in root dir.
    PNA = sparameters('PNA.s2p');
    GEN = sparameters('GEN.s2p');
    %collect frequency and parameter info
    freq = PNA.Frequencies;
    freq2 = GEN.Frequencies;
    if freq ~= freq2
        disp("Frequency ranges don't match!")
        quit
    end
    param = PNA.Parameters;
    param2 = GEN.Parameters;
    %collect S11 and S21 data
    s11_PNA = [];
    s11_GEN = [];
    s21_PNA = [];
    s21_GEN = [];
    for i = 1:10
        s11_PNA = [s11_PNA param(1,1,i)];
        s11_GEN = [s11_GEN param2(1,1,i)];
        s21_PNA = [s21_PNA param(2,1,i)];
        s21_GEN = [s21_GEN param2(2,1,i)];
    end
    %create error for both S11 and S21 & error cutoff line
    S11_error = abs(abs(s11_PNA) - abs(s11_GEN));
    S21_error = abs(abs(s21_PNA) - abs(s21_GEN));
    err = .01;
    cutoff = err*ones(1,length(freq));
    %find number of data points below the error threshold
    S11_thresh = find(S11_error < err);
    S21_thresh = find(S21_error < err);
    %plot S parameters (S11 & S21 for now)
    subplot(3,1,1)
    hold on
    plot(freq,s11_PNA)
    plot(freq,s11_GEN)
    xlabel('Frequency (GHz)')
    ylabel('S11')
    title('S11 Ideal vs Generated')
    legend('Ideal S11','Generated S11')
    
    subplot(3,1,2)
    hold on
    plot(freq,s21_PNA)
    plot(freq,s21_GEN)
    xlabel('Frequency (GHz)')
    ylabel('S21')
    title('S21 Ideal vs Generated')
    legend('Ideal S21','Generated S21')
    %plot error
    subplot(3,1,3)
    hold on
    plot(freq,S11_error)
    plot(freq,S21_error)
    plot(freq,cutoff)
    xlabel('Frequency (GHz)')
    ylabel('Error')
    title('S Parameter Errors')
    legend('S11 Error','S21 Error','Error Cutoff')
    hold off
end