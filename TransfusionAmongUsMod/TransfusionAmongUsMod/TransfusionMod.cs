using System;
using BepInEx;
using BepInEx.IL2CPP;
using BepInEx.Logging;
using UnityEngine;
using CheepsAmongUsApi.API.Events;

namespace TransfusionMod
{
    [BepInPlugin(PluginGuid, PluginName, PluginVersion)]
   
    [BepInDependency(CheepsAmongUsApi.CheepsAmongUs.PluginGuid)]

    [BepInProcess("Among Us.exe")]
    public class TransfusionMod : BasePlugin
    {
        public const string PluginGuid = "org.purnpum.plugins.transfusionmod";
        public const string PluginName = "Transfusion Mod";
        public const string PluginVersion = "1.0.0.0";

        public const string GameModeName = "Transfusion";

        public static ManualLogSource _logger = null;
        public override void Load()
        {
            _logger = Log;
            _logger.LogInfo($"{PluginName} v{PluginVersion} created by PurnPum");

            PlayerUpdateEvent.Listener += () =>
            {
                _logger.LogInfo($"DEBUG : PlayerEvent happened");
            };
        }
    }
}
