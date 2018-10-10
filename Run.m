function Run

if 1 % Human
    help optBiV
    
    [Xmin,Smin] = optBiV(4,{'scalep0','pDropPulm','scaleTubeLArtLen','scaleTubeRArtLen','scaleLv','scaleRvRel','SfAct','SfPas','LAvLeak'},1)
else % Dog
    help optDog
    
    [Xmin,Smin] = optDog(912,{'scalep0','pDropPulm','scaleTubeLArtLen','scaleTubeRArtLen','scaleLv','scaleRvRel','SfAct','SfPas','LAvLeak'},1)

end