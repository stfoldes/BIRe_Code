% EXAMPLE_reshape
%
% reshape from [channel1feature1, chan1,feature2,...] --> [feature x chan] = reshape(x,num_features,num_chan)


%%






%%
x = [1:20];% [1x20]
reshape(x,5,[])
%      1     6    11    16
%      2     7    12    17
%      3     8    13    18
%      4     9    14    19
%      5    10    15    20

y=[1:20]'; % [20x1] WORKS THE SAME
reshape(y,[],4)
reshape(y,5,[])
%      1     6    11    16
%      2     7    12    17
%      3     8    13    18
%      4     9    14    19
%      5    10    15    20

z=[1 2 3 4 5; 6 7 8 9 10; 11 12 13 14 15; 16 17 18 19 20]; % [4x5]
reshape(z,5,4)

z2=[1 2 3 4 5; 6 7 8 9 10; 11 12 13 14 15; 16 17 18 19 20]'; % [4x5]
reshape(z2,5,4)


x = [1 1 1 1; 2 2 2 2; 3 3 3 3; 4 4 4 4; 5 5 5 5; 6 6 6 6]% [channel x feature]
reshape(x,[],6)

x = [11 12 13 14 21 22 23 24 31 32 33 34 41 42 43 44 51 52 53 54 61 62 63 64]% [chan1feature1, chan1,feature2,...]
reshape(x,[],6) % [feature x channel]
%     11    21    31    41    51    61
%     12    22    32    42    52    62
%     13    23    33    43    53    63
%     14    24    34    44    54    64

reshape(x,6,[]) % GARBAGE
%     11    23    41    53
%     12    24    42    54
%     13    31    43    61
%     14    32    44    62
%     21    33    51    63
%     22    34    52    64

clear z3
% times= 3, channels=4, features=2
z3(:,:,1)=[111 121 131 141; 211 221 231 241; 311 321 331 341]; % [time x channels x freq] time1,chan1,freq1
z3(:,:,2)=[112 122 132 142; 212 222 232 242; 312 322 332 342];
% z3(:,:,1) =
%    111   121   131   141
%    211   221   231   241
%    311   321   331   341
% z3(:,:,2) =
%    112   122   132   142
%    212   222   232   242
%    312   322   332   342

temp=reshape(z3,3,[]) % keep time dim, rest is chan1feature1,chan2feature1,...
%    111   121   131   141   112   122   132   142
%    211   221   231   241   212   222   232   242
%    311   321   331   341   312   322   332   342

% [time x chan*feature]
% 2 times, 5 channels, 4 features
x3(1,:) = [111 112 113 114 121 122 123 124 131 132 133 134 141 142 143 144 151 152 153 154]% [chan1feature1, chan1feature2,...]
x3(2,:) = [211 212 213 214 221 222 223 224 231 232 233 234 241 242 243 244 251 252 253 254]% [chan1feature1, chan1feature2,...]

temp = reshape(x3,2,4,[]) % [time x feature x channel]

temp2 = permute(temp,[1 3 2])% [time x channel x feature]






