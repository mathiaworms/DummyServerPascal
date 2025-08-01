unit GamePacketID;

interface

type
  TGamePacketID = (
        BID_Dummy                                 = $0 , 
        S2C_SPM_HierarchicalProfilerUpdate        = $1 , 
        S2C_DisplayLocalizedTutorialChatText      = $2 , 
        S2C_Barrack_SpawnUnit                     = $3 , 
        S2C_SwitchNexusesToOnIdleParticles        = $4 , 
        C2S_TutorialAudioEventFinished            = $5 , 
        S2C_SetCircularMovementRestriction        = $6 , 
        S2C_UpdateGoldRedirectTarget              = $7 , 
        C2S_SynchSimTime                          = $8 , 
        C2S_RemoveItemReq                         = $9 , 
        BID_ResumePacket                          = $A , 
        S2C_RemoveItemAns                         = $B , 
        UNK_Unused_0C                             = $C , 
        S2C_Basic_Attack                          = $D , 
        S2C_RefreshObjectiveText                  = $E , 
        S2C_CloseShop                             = $F , 
        S2C_Reconnect                             = $10 , 
        S2C_UnitAddEXP                            = $11 , 
        S2C_EndSpawn                              = $12 , 
        S2C_SetFrequency                          = $13 , 
        S2C_HighlightTitanBarElement              = $14 , 
        S2C_BotAI                                 = $15 , 
        S2C_TeamSurrenderCountDown                = $16 , 
        C2S_QueryStatusReq                        = $17 , 
        S2C_NPC_UpgradeSpellAns                   = $18 , 
        C2S_Ping_Load_Info                        = $19 , 
        S2C_ChangeSlotSpellType                   = $1A , 
        S2C_NPC_MessageToClient                   = $1B , 
        S2C_DisplayFloatingText                   = $1C , 
        S2C_Basic_Attack_Pos                      = $1D , 
        S2C_NPC_ForceDead                         = $1E , 
        S2C_NPC_BuffUpdateCount                   = $1F , 
        C2S_WriteNavFlags_Acc                     = $20 , 
        S2C_NPC_BuffReplaceGroup                  = $21 , 
        S2C_NPC_SetAutocast                       = $22 , 
        C2S_SwapItemReq                           = $23 , 
        S2C_NPC_Die_EventHistory                  = $24 , 
        S2C_UnitAddGold                           = $25 , 
        S2C_AddUnitPerceptionBubble               = $26 , 
        S2C_MoveCameraToPoint                     = $27 , 
        S2C_LineMissileHitList                    = $28 , 
        S2C_MuteVolumeCategory                    = $29 , 
        S2C_ServerTick                            = $2A , 
        S2C_StopAnimation                         = $2B , 
        S2C_AvatarInfo_Server                     = $2C , 
        S2C_DampenerSwitch                        = $2D , 
        S2C_World_SendCamera_Server_Ack           = $2E , 
        S2C_ModifyDebugCircleRadius               = $2F , 
        C2S_World_SendCamera_Server               = $30 , 
        S2C_HeroReincarnateAlive                  = $31 , 
        S2C_NPC_BuffReplace                       = $32 , 
        S2C_Pause                                 = $33 , 
        S2C_SetFadeOut_Pop                        = $34 , 
        S2C_ChangeSlotSpellName                   = $35 , 
        S2C_ChangeSlotSpellIcon                   = $36 , 
        S2C_ChangeSlotSpellOffsetTarget           = $37 , 
        S2C_RemovePerceptionBubble                = $38 , 
        S2C_NPC_InstantStop_Attack                = $39 , 
        S2C_OnLeaveLocalVisiblityClient           = $3A , 
        S2C_ShowObjectiveText                     = $3B , 
        S2C_CHAR_SpawnPet                         = $3C , 
        S2C_FX_Kill                               = $3D , 
        C2S_NPC_UpgradeSpellReq                   = $3E , 
        C2S_UseObject                             = $3F , 
        UNK_Turret_CreateTurret                   = $40 , 
        S2C_MissileReplication                    = $41 , 
        S2C_ResetForSlowLoader                    = $42 , 
        S2C_HighlightHUDElement                   = $43 , 
        S2C_SwapItemAns                           = $44 , 
        S2C_NPC_LevelUp                           = $45 , 
        S2C_MapPing                               = $46 , 
        S2C_WriteNavFlags                         = $47 , 
        S2C_PlayEmote                             = $48 , 
        S2C_Reconnect_Done                        = $49 , 
        S2C_OnEventWorld                          = $4A ,
        S2C_HeroStats                             = $4B ,
        C2S_PlayEmote                             = $4C , 
        S2C_HeroReincarnate                       = $4D , 
        C2S_OnScoreBoardOpened                    = $4E , 
        S2C_CreateHero                            = $4F , 
        C2S_SPM_AddMemoryListener                 = $50 , 
        S2C_SPM_HierarchicalMemoryUpdate          = $51 , 
        S2C_ToggleUIHighlight                     = $52 , 
        S2C_FaceDirection                         = $53 , 
        S2C_OnLeaveVisiblityClient                = $54 , 
        C2S_ClientReady                           = $55 , 
        S2C_SetItem                               = $56 , 
        S2C_SynchVersion                          = $57 , 
        S2C_HandleTipUpdate                       = $58 , 
        C2S_StatsUpdateReq                        = $59 , 
        C2S_MapPing                               = $5A , 
        S2C_RemoveDebugCircle                     = $5B , 
        S2C_CreateUnitHighlight                   = $5C , 
        S2C_DestroyClientMissile                  = $5D , 
        S2C_LevelUpSpell                          = $5E , 
        S2C_StartGame                             = $5F , 
        C2S_OnShopOpened                          = $60 , 
        S2C_NPC_Hero_Die                          = $61 , 
        S2C_FadeOutMainSFX                        = $62 , 
        UNK_UserMessagesStart                     = $63 ,
        S2C_WaypointGroup                         = $64 , 
        S2C_StartSpawn                            = $65 , 
        S2C_CreateNeutral                         = $66 , 
        S2C_WaypointGroupWithSpeed                = $67 , 
        S2C_UnitApplyDamage                       = $68 , 
        S2C_ModifyShield                          = $69 , 
        S2C_PopCharacterData                      = $6A , 
        S2C_NPC_BuffAddGroup                      = $6B , 
        S2C_AI_TargetSelection                    = $6C , 
        S2C_AI_Target                             = $6D , 
        S2C_SetAnimStates                         = $6E , 
        S2C_ChainMissileSync                      = $6F , 
        C2S_OnTipEvent                            = $70 , 
        S2C_MissileReplication_ChainMissile       = $71 , 
        S2C_BuyItemAns                            = $72 , 
        S2C_SetSpellData                          = $73 , 
        S2C_PauseAnimation                        = $74 , 
        C2S_NPC_IssueOrderReq                     = $75 , 
        S2C_CameraBehavior                        = $76 , 
        S2C_AnimatedBuildingSetCurrentSkin        = $77 , 
        S2C_Connected                             = $78 , 
        S2C_SyncSimTimeFinal                      = $79 , 
        C2S_Waypoint_Acc                          = $7A , 
        S2C_AddPosPerceptionBubble                = $7B , 
        S2C_LockCamera                            = $7C , 
        S2C_PlayVOAudioEvent                      = $7D , 
        C2S_AI_Command                            = $7E , 
        S2C_NPC_BuffRemove2                       = $7F , 
        S2C_SpawnMinion                           = $80 , 
        C2S_ClientCheatDetectionSignal            = $81 , 
        S2C_ToggleFoW                             = $82 , 
        S2C_ToolTipVars                           = $83 , 
        S2C_UnitApplyHeal                         = $84 , 
        S2C_GlobalCombatMessage                   = $85 , 
        C2S_World_LockCamera_Server               = $86 , 
        C2S_BuyItemReq                            = $87 , 
        S2C_WaypointListHeroWithSpeed             = $88 , 
        S2C_SetInputLockingFlag                   = $89 , 
        S2C_CHAR_SetCooldown                      = $8A , 
        S2C_CHAR_CancelTargetingReticle           = $8B , 
        S2C_FX_Create_Group                       = $8C , 
        S2C_QueryStatusAns                        = $8D , 
        S2C_Building_Die                          = $8E , 
        C2S_SPM_RemoveListener                    = $8F , 
        S2C_HandleQuestUpdate                     = $90 , 
        C2S_ClientFinished                        = $91 , 
        UNK_CHAT                                  = $92 , 
        C2S_SPM_RemoveMemoryListener              = $93 , 
        C2S_Exit                                  = $94 , 
        S2C_ServerGameSettings                    = $95 , 
        S2C_ModifyDebugCircleColor                = $96 , 
        C2S_SPM_AddListener                       = $97 , 
        S2C_World_SendGameNumber                  = $98 , 
        S2C_ChangePARColorOverride                = $99 , 
        UNK_ClientConnect_NamedPipe               = $9A , 
        S2C_NPC_BuffRemoveGroup                   = $9B , 
        UNK_Turret_Fire                           = $9C , 
        S2C_Ping_Load_Info                        = $9D , 
        S2C_ChangeCharacterVoice                  = $9E , 
        S2C_ChangeCharacterData                   = $9F , 
        S2C_Exit                                  = $A0 , 
        C2S_SPM_RemoveBBProfileListener           = $A1 , 
        C2S_NPC_CastSpellReq                      = $A2 , 
        S2C_ToggleInputLockingFlag                = $A3 , 
        C2S_Reconnect                             = $A4 , 
        S2C_CreateTurret                          = $A5 , 
        S2C_NPC_Die                               = $A6 , 
        S2C_UseItemAns                            = $A7 , 
        S2C_ShowAuxiliaryText                     = $A8 , 
        BID_PausePacket                           = $A9 , 
        S2C_HideObjectiveText                     = $AA , 
        S2C_OnEvent                               = $AB , 
        C2S_TeamSurrenderVote                     = $AC , 
        S2C_TeamSurrenderStatus                   = $AD , 
        C2S_SPM_AddBBProfileListener              = $AE , 
        S2C_HideAuxiliaryText                     = $AF , 
        C2S_OnReplication_Acc                     = $B0 , 
        UNK_OnDisconnected                        = $B1 , 
        S2C_SetGreyscaleEnabledWhenDead           = $B2 , 
        S2C_AI_State                              = $B3 , 
        S2C_SetFoWStatus                          = $B4 , 
        // UNK_ReloadScripts,
        // UNK_Cheat,
        S2C_OnEnterLocalVisiblityClient           = $B5 , 
        S2C_HighlightShopElement                  = $B6 , 
        C2S_SendSelectedObjID                     = $B7 , 
        S2C_PlayAnimation                         = $B8 , 
        S2C_RefreshAuxiliaryText                  = $B9 , 
        S2C_SetFadeOut_Push                       = $BA , 
        S2C_OpenTutorialPopup                     = $BB , 
        S2C_RemoveUnitHighlight                   = $BC , 
        S2C_NPC_CastSpellAns                      = $BD , 
        S2C_SPM_HierarchicalBBProfileUpdate       = $BE , 
        S2C_NPC_BuffAdd2                          = $BF , 
        S2C_OpenAFKWarningMessage                 = $C0 , 
        S2C_WaypointList                          = $C1 , 
        S2C_OnEnterVisiblityClient                = $C2 , 
        S2C_AddDebugCircle                        = $C3 , 
        S2C_DisableHUDForEndOfGame                = $C4 , 
        C2S_SynchVersion                          = $C5 , 
        C2S_CharSelected                          = $C6 , 
        S2C_NPC_BuffUpdateCountGroup              = $C7 , 
        S2C_AI_TargetHero                         = $C8 , 
        S2C_SynchSimTime                          = $C9 , 
        S2C_SyncMissionStartTime                  = $CA , 
        S2C_Neutral_Camp_Empty                    = $CB , 
        S2C_OnReplication                         = $CC , 
        S2C_EndOfGameEvent                        = $CD , 
        S2C_EndGame                               = $CE , 
        UNK_Undefined                             = $CF , 
        S2C_SPM_SamplingProfilerUpdate            = $D0 , 
        S2C_PopAllCharacterData                   = $D1 , 
        S2C_TeamSurrenderVote                     = $D2 , 
        S2C_HandleUIHighlight                     = $D3 , 
        S2C_FadeMinions                           = $D4 , 
        C2S_OnTutorialPopupClosed                 = $D5 , 
        C2S_OnQuestEvent                          = $D6 , 
        S2C_ShowHealthBar                         = $D7 , 
        S2C_SpawnBot                              = $D8 , 
        S2C_SpawnLevelProp                        = $D9 , 
        S2C_UpdateLevelProp                       = $DA , 
        S2C_AttachFlexParticle                    = $DB , 
        S2C_HandleCapturePointUpdate              = $DC , 
        S2C_HandleGameScore                       = $DD , 
        S2C_HandleRespawnPointUpdate              = $DE , 
        C2S_OnRespawnPointEvent                   = $DF , 
        S2C_UnitChangeTeam                        = $E0 , 
        S2C_UnitSetMinimapIcon                    = $E1 , 
        S2C_IncrementPlayerScore                  = $E2 , 
        S2C_IncrementPlayerStat                   = $E3 , 
        S2C_ColorRemapFX                          = $E4 , 
        S2C_MusicCueCommand                       = $E5 , 
        S2C_AntiBot                               = $E6 , 
        S2C_AntiBotWriteLog                       = $E7 , 
        S2C_AntiBotKickOut                        = $E8 , 
        S2C_AntiBotBanPlayer                      = $E9 , 
        S2C_AntiBotTrojan                         = $EA , 
        S2C_AntiBotCloseClient                    = $EB , 
        C2S_AntiBotDP                             = $EC , 
        C2S_AntiBot                               = $ED , 
        S2C_OnEnterTeamVisiblity                  = $EE , 
        S2C_OnLeaveTeamVisiblity                  = $EF , 
        S2C_FX_OnEnterTeamVisiblity               = $F0 , 
        S2C_FX_OnLeaveTeamVisiblity               = $F1 , 
        S2C_ReplayOnly_GoldEarned                 = $F2 , 

        ExtendedPacket                           = $FE,
        Batch                                    = $FF
  );

implementation

end.
